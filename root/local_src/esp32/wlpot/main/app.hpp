#include <udp.h>
#include <analog.h>
#include <serial.h>

#define APP_NET_IP			"192.168.173.81"
#define APP_LOOP_PERIOD		1000

#define ADC_POT				6
#define GPIO_LED			GPIO_NUM_13


UdpSlave<512> slave(55211);


void init(const JsonObject cfg)
{
	gpio_init_pin_output(GPIO_LED);
}


double pot()
{
	return analog_voltage(ADC_POT) / 3300.0;
}


void slaveReceive(JsonDocument& msg)
{
	msg["pot"] = pot();
	msg["signal"] = wifi_signal();
}

void start()
{
	slave.start(slaveReceive);
}


void serial_receive(char cmd)
{
	switch (cmd) {
		default:
			printf("pot=%f\n", pot());
	}
}


void loop()
{
	if (slave.connected) {
		gpio_set_level(GPIO_LED, true);
		vTaskDelay(pdMS_TO_TICKS(150));
		gpio_set_level(GPIO_LED, false);
	}
}
