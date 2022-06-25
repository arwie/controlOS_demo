
#include <lely/ev/loop.hpp>
#include <lely/io2/linux/can.hpp>
#include <lely/io2/posix/poll.hpp>

#include <lely/io2/sys/io.hpp>
#include <lely/io2/sys/sigset.hpp>
#include <lely/io2/sys/timer.hpp>
#include <lely/coapp/fiber_driver.hpp>
#include <lely/coapp/master.hpp>


#include <thread>
#include <pthread.h>

#include <bitset>
#include <iostream>
using namespace std;
using namespace std::chrono_literals;
using namespace lely;

int enable = false;
bool enabled = false;
uint16_t pdo_status;
int32_t  pdo_pfb;
int32_t  pdo_vfb;
uint16_t errorCode = 0;




// This driver inherits from FiberDriver, which means that all CANopen event
// callbacks, such as OnBoot, run as a task inside a "fiber" (or stackful
// coroutine).
class MyDriver : public canopen::FiberDriver {
 public:
  using FiberDriver::FiberDriver;

 private:
  // This function gets called when the boot-up process of the slave completes.
  // The 'st' parameter contains the last known NMT state of the slave
  // (typically pre-operational), 'es' the error code (0 on success), and 'what'
  // a description of the error, if any.
  void OnBoot(canopen::NmtState /*st*/, char es, const std::string& what) noexcept override {
    if (!es || es == 'L') {
      cout << "slave " << static_cast<int>(id()) << " booted sucessfully"
                << std::endl;


    } else {
      cout << "slave " << static_cast<int>(id())
                << " failed to boot: " << what << std::endl;
    }
  }

  // This function gets called during the boot-up process for the slave. The
  // 'res' parameter is the function that MUST be invoked when the configuration
  // is complete. Because this function runs as a task inside a coroutine, it
  // can suspend itself and wait for an asynchronous function, such as an SDO
  // request, to complete.
  void OnConfig(std::function<void(std::error_code ec)> res) noexcept override {
    try {
      // Perform a few SDO write requests to configure the slave. The
      // AsyncWrite() function returns a future which becomes ready once the
      // request completes, and the Wait() function suspends the coroutine for
      // this task until the future is ready.

      // Configure the slave to monitor the heartbeat of the master (node-ID 1)
      // with a timeout of 2000 ms.
//      Wait(AsyncWrite<uint32_t>(0x1016, 1, (1 << 16) | 2000));
      // Configure the slave to produce a heartbeat every 1000 ms.
//      Wait(AsyncWrite<uint16_t>(0x1017, 0, 1000));
      // Configure the heartbeat consumer on the master.
//      ConfigHeartbeat(2000ms);

      // Reset object 4000:00 and 4001:00 on the slave to 0.
//      Wait(AsyncWrite<uint32_t>(0x4000, 0, 0));
//      Wait(AsyncWrite<uint32_t>(0x4001, 0, 0));

      // Report success (empty error code).
      res({});
    } catch (canopen::SdoError& e) {
      // If one of the SDO requests resulted in an error, abort the
      // configuration and report the error code.
      res(e.code());
    }
  }


  // This function gets called every time a value is written to the local object
  // dictionary of the master by an RPDO (or SDO, but that is unlikely for a
  // master), *and* the object has a known mapping to an object on the slave for
  // which this class is the driver. The 'idx' and 'subidx' parameters are the
  // object index and sub-index of the object on the slave, not the local object
  // dictionary of the master.
	void OnRpdoWrite(uint16_t idx, uint8_t subidx) noexcept override {
		switch (idx) {
		case 0x6041:
			pdo_status	= rpdo_mapped[0x6041][0];
			if (enable == 1) {
				if (pdo_status & 0b1000) {
					SubmitRead<uint16_t>(0x603F, 0, [](uint8_t id, uint16_t idx, uint8_t subidx, ::std::error_code ec, uint16_t value){errorCode = value;});
					enable = false;
				}
				int16_t control = 0;
				switch (pdo_status & 0b111) {
				case 0b000:	control = 0x06; enabled = true; break;
				case 0b001:	control = 0x07; break;
				case 0b011:	control = 0x0F; break;
				case 0b111:	control = 0x1F; break;
				}
				tpdo_mapped[0x6040][0] = control;
			}
			break;
		case 0x6064:
			pdo_pfb	= rpdo_mapped[0x6064][0];
			if (!enabled)
				tpdo_mapped[0x607A][0] = pdo_pfb;
			break;
		case 0x606C:
			pdo_vfb	= rpdo_mapped[0x606C][0];
			if (pdo_vfb > 5000)
				enable = -1;
			if (enable == -1 && pdo_vfb == 0)
				enable = 1;
			break;
		}
	}
};


int main() {
	cout << "Hello CANopen 2!" << endl;

  // Initialize the I/O library. This is required on Windows, but a no-op on
  // Linux (for now).
  io::IoGuard io_guard;
  // Create an I/O context to synchronize I/O services during shutdown.
  io::Context ctx;
  // Create an platform-specific I/O polling instance to monitor the CAN bus, as
  // well as timers and signals.
  io::Poll poll(ctx);
  // Create a polling event loop and pass it the platform-independent polling
  // interface. If no tasks are pending, the event loop will poll for I/O
  // events.
  ev::Loop loop(poll.get_poll());
  // I/O devices only need access to the executor interface of the event loop.
  auto exec = loop.get_executor();
  // Create a timer using a monotonic clock, i.e., a clock that is not affected
  // by discontinuous jumps in the system time.
  io::Timer timer(poll, exec, CLOCK_MONOTONIC);
  // Create a virtual SocketCAN CAN controller and channel, and do not modify
  // the current CAN bus state or bitrate.
  io::CanController ctrl("can0");
  io::CanChannel chan(poll, exec);
  chan.open(ctrl);

  // Create a CANopen master with node-ID 1. The master is asynchronous, which
  // means every user-defined callback for a CANopen event will be posted as a
  // task on the event loop, instead of being invoked during the event
  // processing by the stack.
  canopen::AsyncMaster master(timer, chan, "master.dcf", "", 1);

  // Create a driver for the slave with node-ID 2.
  MyDriver driver(exec, master, 5);

  // Create a signal handler.
  io::SignalSet sigset(poll, exec);
  // Watch for Ctrl+C or process termination.
  sigset.insert(SIGHUP);
  sigset.insert(SIGINT);
  sigset.insert(SIGTERM);

  // Submit a task to be executed when a signal is raised. We don't care which.
  sigset.submit_wait([&](int /*signo*/) {
    // If the signal is raised again, terminate immediately.
    sigset.clear();
    // Tell the master to start the deconfiguration process for all nodes, and
    // submit a task to be executed once that process completes.
    master.AsyncDeconfig().submit(exec, [&]() {
      // Perform a clean shutdown.
      ctx.shutdown();
    });
  });

  // Start the NMT service of the master by pretending to receive a 'reset
  // node' command.
  master.Reset();


	thread([]() {for (;;) {
		cout <<dec<< "en:"<<enable << " - status:"<<std::bitset<16>(pdo_status) << " - pfb:"<<pdo_pfb << " - vfb:"<<pdo_vfb << " - err:"<<hex<<errorCode  << endl;
		this_thread::sleep_for(std::chrono::milliseconds(333));
	}}).detach();


	struct sched_param param; param.sched_priority = 10;
	pthread_setschedparam(pthread_self(), SCHED_FIFO, &param);
  // Run the event loop until no tasks remain (or the I/O context is shut down).
  loop.run();

  return 0;
}




