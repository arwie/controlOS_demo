#define APP_NET_IP			"192.168.173.81"
#define APP_LOOP_PERIOD		1000


void init(const JsonObject cfg)
{
	ESP_LOGI(TAG, "init");
}

void start()
{
	ESP_LOGI(TAG, "start");
}


void loop()
{
	static int i = 0;
	ESP_LOGI(TAG, "loop cycle %i", ++i);
}
