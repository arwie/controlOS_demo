
#include <lely/ev/loop.hpp>
#include <lely/io2/linux/can.hpp>
#include <lely/io2/posix/poll.hpp>

#include <lely/io2/sys/io.hpp>
#include <lely/io2/sys/sigset.hpp>
#include <lely/io2/sys/timer.hpp>
#include <lely/coapp/fiber_driver.hpp>
#include <lely/coapp/master.hpp>

#include <ruckig/ruckig.hpp>

#include <random>
#include <thread>
#include <sched.h>
#include <unistd.h>
#include <sys/mman.h>
#include <malloc.h>

#include <math.h>
#define PI 3.14159265

#include <bitset>
#include <iostream>
using namespace std;
using namespace std::chrono_literals;
using namespace lely;

bool enabled = false;
int32_t  pcmd, pcmd0;
uint16_t pdo_status;
int32_t  pdo_pfb;
int32_t  pdo_pll, pllMax = 0;
uint16_t errorCode = 0;
chrono::microseconds syncJitter = {};

using namespace ruckig;
Ruckig<1> otg {0.004};
InputParameter<1> otgInput;
OutputParameter<1> otgOutput;
double otgCalcTimeMax = 0;

const double bounds = 5*4096;
uniform_real_distribution<double> unif(-bounds, bounds);
default_random_engine re;


inline void calcJitter() {
	static chrono::time_point<chrono::steady_clock> lastSync = {};
	auto thisSync = chrono::steady_clock::now();
	auto thisJitter = chrono::duration_cast<chrono::microseconds>(thisSync - lastSync) - chrono::microseconds(4000);
	if (thisJitter > syncJitter)
		syncJitter = thisJitter;
	lastSync = thisSync;
}


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
      cout << "slave " << static_cast<int>(id()) << " booted sucessfully" << std::endl;
    } else {
      cout << "slave " << static_cast<int>(id()) << " failed to boot: " << what << std::endl;
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
		int16_t control = 0;
		switch (idx) {
		case 0x6041:
			pdo_status	= rpdo_mapped[0x6041][0];
			switch (pdo_status & 0b111) {
			case 0b000:	control = 0x06; break;
			case 0b001:	control = 0x07; break;
			case 0b011:	control = 0x0F; break;
			case 0b111:	control = 0x1F; enabled = true; break;
			}
			if (!errorCode && (pdo_status & 0b1000)) {
				errorCode = -1;
				SubmitRead<uint16_t>(0x603F, 0, [](uint8_t id, uint16_t idx, uint8_t subidx, error_code ec, uint16_t value){errorCode = value;});
			}
			tpdo_mapped[0x6040][0] = control;
			break;
		case 0x6064:
			pdo_pfb	= rpdo_mapped[0x6064][0];
			if (!enabled) {
				pcmd0 = pcmd = pdo_pfb;
				otgInput.current_position = {(double)pdo_pfb};
				otgInput.target_position  = {(double)pdo_pfb};
			}
			break;
		case 0x2618:
			pdo_pll = rpdo_mapped[0x2618][0];
			pllMax = max(pdo_pll, pllMax);
			break;
		}
	}

	void OnSync(uint8_t cnt, const time_point& t) noexcept override {
		//static double sinTime = 0.0;

		calcJitter();

		if (enabled) {
			//pcmd = pcmd0 + 3000*(cos(0.4*sinTime)-1) - 2000*(cos(1.2*sinTime)-1);
			//sinTime += 2*PI / 250;

			if (otg.update(otgInput, otgOutput) == Result::Working) {
				pcmd = otgOutput.new_position[0];
				otgCalcTimeMax = max(otgCalcTimeMax, otgOutput.calculation_duration);
				otgOutput.pass_to_input(otgInput);
			} else {
				otgInput.target_position = {(double)pdo_pfb + unif(re)};
			}
		}
		tpdo_mapped[0x607A][0] = pcmd;
	}
};


static void setprio(int prio, int sched = SCHED_FIFO) {
	struct sched_param param;
	param.sched_priority = prio;
	if (sched_setscheduler(0, sched, &param) < 0)
		perror("sched_setscheduler");
}

static void configure_malloc_behavior(void) {
	/* Now lock all current and future pages
	 from preventing of being paged */
	if (mlockall(MCL_CURRENT | MCL_FUTURE))
		perror("mlockall failed:");

	/* Turn off malloc trimming.*/
	mallopt(M_TRIM_THRESHOLD, -1);

	/* Turn off mmap usage. */
	mallopt(M_MMAP_MAX, 0);
}

static void reserve_process_memory(int size) {
	int i;
	char *buffer;

	buffer = (char*)malloc(size);

	/* Touch each page in this piece of memory to get it mapped into RAM */
	for (i = 0; i < size; i += sysconf(_SC_PAGESIZE)) {
		/* Each write to this buffer will generate a pagefault.
		 Once the pagefault is handled a page will be locked in
		 memory and never given back to the system. */
		buffer[i] = 0;
	}

	/* buffer will now be released. As Glibc is configured such that it
	 never gives back memory to the kernel, the memory allocated above is
	 locked for this process. All malloc() and new() calls come from
	 the memory pool reserved and locked above. Issuing free() and
	 delete() does NOT make this locking undone. So, with this locking
	 mechanism we can build C++ applications that will never run into
	 a major/minor pagefault, even with swapping enabled. */
	free(buffer);
}


int main() {
	cout << "Hello openIMC!" << endl;


	thread([]() {for (;;this_thread::sleep_for(chrono::milliseconds(1000))) {
		cout << "status:"<<bitset<16>(pdo_status) << " - pfb:"<<dec<<pdo_pfb << " - pll:"<<dec<<pdo_pll<<":"<<pllMax << " - jitter:"<<dec<<syncJitter.count() << " - otgCalcTime:"<<dec<<otgOutput.calculation_duration<<":"<<otgCalcTimeMax << " - err:"<<hex<<errorCode  << endl;
		pllMax = 0;
		syncJitter = chrono::microseconds::zero();
		otgCalcTimeMax = 0;
	}}).detach();


	configure_malloc_behavior();
	reserve_process_memory(10 * 1024 * 1024);

	system("chrt -fp 90 $(pgrep irq/.*-can0)");
	system("chrt -fp 60 $(pgrep ksoftirqd/0)");

	setprio(80);
	//for (;;this_thread::sleep_for(chrono::microseconds(4000))) calcJitter();	//test RT


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


    otgInput.max_velocity		= { 5 * 4096 };
    otgInput.max_acceleration	= { 1000/300 * otgInput.max_velocity[0]  };
    otgInput.max_jerk			= { 1000/150 * otgInput.max_acceleration[0] };

	// Run the event loop until no tasks remain (or the I/O context is shut down).
	loop.run();

	return 0;
}




