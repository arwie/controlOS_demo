
#include <ecrt.h>

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

#include <ruckig/ruckig.hpp>
using namespace ruckig;
Ruckig<1> otg {0.004};
InputParameter<1> otgInput;
OutputParameter<1> otgOutput;
double otgCalcTimeMax = 0;
uniform_real_distribution<double> unif(0, 3*1000000);
default_random_engine re;


chrono::microseconds syncJitter = {};
inline void calcJitter() {
	static chrono::time_point<chrono::steady_clock> lastSync = {};
	auto thisSync = chrono::steady_clock::now();
	auto thisJitter = chrono::duration_cast<chrono::microseconds>(thisSync - lastSync) - chrono::microseconds(4000);
	if (thisJitter > syncJitter)
		syncJitter = thisJitter;
	lastSync = thisSync;
}


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



#define PERIOD_NS   (4000000)
#define NSEC_PER_SEC (1000000000)
#define TIMESPEC2NS(T) ((uint64_t) (T).tv_sec * NSEC_PER_SEC + (T).tv_nsec)


static ec_master_t *master = NULL;
static ec_domain_t *domain1 = NULL;
static uint8_t *domain1_pd = NULL;
static ec_slave_config_t *cdhd = NULL;

static uint16_t status = 0, errorCode = 0;
static int32_t pfb = -123, offset = 0;
static int32_t pcmd;

static int off_control, off_pcmd;
static int off_status, off_pfb;
static bool enabled = false;


void cyclic_task()
{
	calcJitter();

    // receive process data
    ecrt_master_receive(master);
    ecrt_domain_process(domain1);

    status	= EC_READ_U16(domain1_pd + off_status);
    pfb		= EC_READ_S32(domain1_pd + off_pfb);

	if (!enabled) {
		pcmd = offset = pfb;
	} else {
		if (otg.update(otgInput, otgOutput) == Result::Working) {
			pcmd = otgOutput.new_position[0] + offset;
			otgCalcTimeMax = max(otgCalcTimeMax, otgOutput.calculation_duration);
			otgOutput.pass_to_input(otgInput);
		} else {
			otgInput.target_position = {unif(re)};
		}
	}

    int16_t control = 0;
	switch (status & 0b111) {
    	case 0b000:	control = 0x06; break;
    	case 0b001:	control = 0x07; break;
    	case 0b011:	control = 0x0F; break;
    	case 0b111:	control = 0x1F; enabled = true; break;
	}

	EC_WRITE_U16(domain1_pd + off_control, control);
	EC_WRITE_S32(domain1_pd + off_pcmd, pcmd);

	struct timespec time;
	clock_gettime(CLOCK_MONOTONIC, &time);
	//ecrt_master_sync_reference_clock(master);
	//ecrt_master_sync_slave_clocks(master);

    // send process data
    ecrt_domain_queue(domain1);
    ecrt_master_send(master);
}

template<class type>
void sdoWrite(uint16_t slave, uint16_t index, uint8_t subIndex, const type value) {
	uint32_t abort_code;
	if (ecrt_master_sdo_download(master, slave, index, subIndex, (uint8_t *)&value, sizeof(type), &abort_code))
		cout << "ERROR: ecrt_master_sdo_download: " << abort_code << endl;

}

int main() {
	cout << "Hello openIMC!" << endl;

    const double vmax = 2.5*1000000;		otgInput.max_velocity		= { vmax };
    const double amax = vmax*1000/200;		otgInput.max_acceleration	= { amax };
    const double jmax = amax*1000/100;		otgInput.max_jerk			= { jmax };
    otgInput.synchronization = Synchronization::Phase;

	thread([]() {for (;;this_thread::sleep_for(chrono::milliseconds(1000))) {
		cout << "status:"<<bitset<16>(status) << " - pfb:"<<dec<<pfb << " - jitter:"<<dec<<syncJitter.count() << " - otgCalcTime:"<<dec<<otgOutput.calculation_duration<<":"<<otgCalcTimeMax << " - err:"<<hex<<errorCode  << endl;
		syncJitter = chrono::microseconds::zero();
		otgCalcTimeMax = 0;
	}}).detach();

	configure_malloc_behavior();
	reserve_process_memory(10 * 1024 * 1024);

	//system("chrt -fp 90 $(pgrep irq/44-4a100000)");
	//system("chrt -fp 90 $(pgrep irq/45-4a100000)");
	//system("chrt -fp 60 $(pgrep ksoftirqd/0)");

	master = ecrt_request_master(0);
	if (!master) {
		cout << "ERROR: ecrt_request_master" << endl;
	}

	sdoWrite<int8_t>(0, 0x1C12, 0, 0);
	sdoWrite<int16_t>(0, 0x1C12, 1, 0x1600);
	sdoWrite<int8_t>(0, 0x1C12, 0, 1);

	sdoWrite<int8_t>(0, 0x1600, 0, 0);
	sdoWrite<int32_t>(0, 0x1600, 1, 0x60400010);
	sdoWrite<int32_t>(0, 0x1600, 2, 0x607A0020);
	sdoWrite<int8_t>(0, 0x1600, 0, 2);

	sdoWrite<int8_t>(0, 0x1C13, 0, 0);
	sdoWrite<int16_t>(0, 0x1C13, 1, 0x1A00);
	sdoWrite<int8_t>(0, 0x1C13, 0, 1);

	sdoWrite<int8_t>(0, 0x1A00, 0, 0);
	sdoWrite<int32_t>(0, 0x1A00, 1, 0x60410010);
	sdoWrite<int32_t>(0, 0x1A00, 2, 0x60640020);
	sdoWrite<int8_t>(0, 0x1A00, 0, 2);

	sdoWrite<int16_t>(0, 0x6040, 0, 0x80);	//reset faluts
	sdoWrite<int8_t>(0, 0x6060, 0, 8);		//Modes of Operation: 8 [cyclic synchronous position mode]

	sdoWrite<int8_t>(0, 0x60C2, 1, 4000/100);
	sdoWrite<int8_t>(0, 0x60C2, 2, -4);

	domain1 = ecrt_master_create_domain(master);
	if (!domain1) {
		cout << "ERROR: ecrt_master_create_domain" << endl;
	}

	if (!(cdhd = ecrt_master_slave_config(master, 0,0, 0x000002e1,0x00000000))) {
		cout << "ERROR: ecrt_master_slave_config" << endl;
	}

	off_control = ecrt_slave_config_reg_pdo_entry(cdhd, 0x6040, 0, domain1, NULL);
	if (off_control < 0)
		cout << "ERROR: ecrt_slave_config_reg_pdo_entry(control)" << endl;

	off_pcmd = ecrt_slave_config_reg_pdo_entry(cdhd, 0x607A, 0, domain1, NULL);
	if (off_pcmd < 0)
		cout << "ERROR: ecrt_slave_config_reg_pdo_entry(pcmd)" << endl;

	off_status = ecrt_slave_config_reg_pdo_entry(cdhd, 0x6041, 0, domain1, NULL);
	if (off_status < 0)
		cout << "ERROR: ecrt_slave_config_reg_pdo_entry(status)" << endl;

	off_pfb = ecrt_slave_config_reg_pdo_entry(cdhd, 0x6064, 0, domain1, NULL);
	if (off_pfb < 0)
		cout << "ERROR: ecrt_slave_config_reg_pdo_entry(pfb)" << endl;

	// configure SYNC signals for this slave
	ecrt_slave_config_dc(cdhd, 0x0700, PERIOD_NS, 4400000, 0, 0);

	printf("Activating master...\n");
	if (ecrt_master_activate(master))
		cout << "ERROR: ecrt_master_activate" << endl;

	if (!(domain1_pd = ecrt_domain_data(domain1))) {
		cout << "ERROR: ecrt_domain_data" << endl;
	}

	setprio(80);

	struct timespec wakeup_time;
    clock_gettime(CLOCK_MONOTONIC, &wakeup_time);
    wakeup_time.tv_sec += 1; /* start in future */
    wakeup_time.tv_nsec = 0;

    while (1) {
        clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &wakeup_time, NULL);

        ecrt_master_application_time(master, TIMESPEC2NS(wakeup_time));

        cyclic_task();

        wakeup_time.tv_nsec += PERIOD_NS;
        while (wakeup_time.tv_nsec >= NSEC_PER_SEC) {
            wakeup_time.tv_nsec -= NSEC_PER_SEC;
            wakeup_time.tv_sec++;
        }
    }



	return 0;
}




