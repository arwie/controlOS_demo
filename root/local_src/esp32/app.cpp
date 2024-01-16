// Copyright (c) 2023 Artur Wiebe <artur@4wiebe.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include <esp_log.h>
#include <esp_wifi.h>
#include <esp_eth.h>
#include <esp_http_client.h>
#include <esp_ota_ops.h>

#include <ArduinoJson.h>
#include "util.h"

using namespace std;

static const char* TAG = "app";


#include <app.hpp>


#ifndef APP_NET_ETH
static void main_wifiScan(void* arg, esp_event_base_t, int32_t, void*)
{
	ESP_LOGI(TAG, "wifiScan");
	wifi_scan_config_t scanConfig = {};
	scanConfig.bssid = ((wifi_config_t*)arg)->sta.bssid;
	ESP_ERROR_CHECK(esp_wifi_scan_start(&scanConfig, false));
}

static void main_wifiConnect(void* arg, esp_event_base_t, int32_t, void*)
{
	ESP_LOGI(TAG, "wifiConnect");
	
	uint16_t apMax = 1, apCount = 0; wifi_ap_record_t apInfo = {};
	ESP_ERROR_CHECK(esp_wifi_scan_get_ap_records(&apMax, &apInfo));
	ESP_ERROR_CHECK(esp_wifi_scan_get_ap_num(&apCount));
	if (!apCount) {
		ESP_LOGE(TAG, "wifi ap not found");
		esp_restart();
	}
	wifi_config_t* wifiConfig = (wifi_config_t*) arg;
	strncpy((char*) wifiConfig->sta.ssid, (char*) apInfo.ssid, sizeof(wifiConfig->sta.ssid));
	ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, wifiConfig));
	ESP_ERROR_CHECK(esp_wifi_connect());
}
#endif

static void main_networkConnected(void* arg, esp_event_base_t, int32_t, void*) {
	ESP_LOGI(TAG, "networkConnected");
	xSemaphoreGive(*((SemaphoreHandle_t*)arg));
}

static void main_networkDisconnected(void*, esp_event_base_t, int32_t, void*) {
	ESP_LOGE(TAG, "networkDisconnected");
	esp_restart();
}


static void main_init()
{
	//### open cfg partition
	DynamicJsonDocument cfg(1024);
	const esp_partition_t *cfgPart = esp_partition_find_first(ESP_PARTITION_TYPE_DATA, ESP_PARTITION_SUBTYPE_ANY, "cfg");
	const char *cfgData; spi_flash_mmap_handle_t cfgDataHandle;
	ESP_ERROR_CHECK(esp_partition_mmap(cfgPart, 0, cfgPart->size, SPI_FLASH_MMAP_DATA, (const void**) &cfgData, &cfgDataHandle));
	deserializeJson(cfg, cfgData);

	//### networking init
	ESP_ERROR_CHECK(esp_netif_init());
	ESP_ERROR_CHECK(esp_event_loop_create_default());
	esp_netif_t	*netif = NULL;
	StaticSemaphore_t networkConnectedSemaphoreBuffer;
	SemaphoreHandle_t networkConnectedSemaphore = xSemaphoreCreateBinaryStatic(&networkConnectedSemaphoreBuffer);

	#ifdef APP_NET_ETH

		//### ehternet init
		esp_eth_config_t ethConfig = APP_NET_ETH();
		esp_netif_config_t ethNetifConfig = ESP_NETIF_DEFAULT_ETH();
		netif = esp_netif_new(&ethNetifConfig);
		esp_eth_handle_t ethHandle = NULL;
		ESP_ERROR_CHECK(esp_eth_driver_install(&ethConfig, &ethHandle));
		ESP_ERROR_CHECK(esp_netif_attach(netif, esp_eth_new_netif_glue(ethHandle)));

		//### ethernet start
		esp_event_handler_instance_t ethConnectedHandler, ethDisconnectedHandler;
		ESP_ERROR_CHECK(esp_event_handler_instance_register(ETH_EVENT, ETHERNET_EVENT_CONNECTED,    &main_networkConnected, &networkConnectedSemaphore, &ethConnectedHandler));
		ESP_ERROR_CHECK(esp_event_handler_instance_register(ETH_EVENT, ETHERNET_EVENT_DISCONNECTED, &main_networkDisconnected, NULL, &ethDisconnectedHandler));
		ESP_ERROR_CHECK(esp_eth_start(ethHandle));

	#else

		//### wifi sta init
		netif = esp_netif_create_default_wifi_sta();
		wifi_init_config_t wifiInitConfig = WIFI_INIT_CONFIG_DEFAULT();
		ESP_ERROR_CHECK(esp_wifi_init(&wifiInitConfig));
		ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
		
		//### wifi config
		wifi_config_t wifiConfig = {};
		JsonObject cfgWifi = cfg["wifi"]; JsonArray cfgWifiBssid = cfgWifi["bssid"];
		strncpy((char*) wifiConfig.sta.password, cfgWifi["psk"], sizeof(wifiConfig.sta.password));
		for (int i=0; i<6; ++i)
			wifiConfig.sta.bssid[i] = cfgWifiBssid[i];
		
		//### wifi start
		esp_event_handler_instance_t wifiScanHandler, wifiConnectHandler, wifiConnectedHandler, wifiDisconnectedHandler;
		ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT, WIFI_EVENT_STA_START,        &main_wifiScan,         &wifiConfig, &wifiScanHandler));
		ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT, WIFI_EVENT_SCAN_DONE,        &main_wifiConnect,      &wifiConfig, &wifiConnectHandler));
		ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT, WIFI_EVENT_STA_CONNECTED,    &main_networkConnected, &networkConnectedSemaphore, &wifiConnectedHandler));
		ESP_ERROR_CHECK(esp_event_handler_instance_register(WIFI_EVENT, WIFI_EVENT_STA_DISCONNECTED, &main_networkDisconnected, NULL, &wifiDisconnectedHandler));
		ESP_ERROR_CHECK(esp_wifi_start());

	#endif
	
	//### static ip
	#ifndef APP_NET_IP
		#define APP_NET_IP cfg["net"]["ip"]
	#endif
	esp_netif_ip_info_t ipInfo = {};
	IP4_ADDR(&ipInfo.netmask, 255, 255, 255, 0);
	ipInfo.ip.addr = ipaddr_addr(APP_NET_IP);
	ESP_ERROR_CHECK(esp_netif_dhcpc_stop(netif));
	ESP_ERROR_CHECK(esp_netif_set_ip_info(netif, &ipInfo));
	
	//### init plugins
	#ifdef APP_NVS_INIT
		APP_NVS_INIT;
	#endif
	#ifdef APP_SERIAL_INIT
		APP_SERIAL_INIT;
	#endif
	#ifdef APP_ANALOG_INIT
		APP_ANALOG_INIT;
	#endif
	
	//### app init
	ESP_LOGI(TAG, "app init");
	init(cfg.as<JsonObject>());

	//### wait network connected
	if (!xSemaphoreTake(networkConnectedSemaphore, pdMS_TO_TICKS(30000))) {
		ESP_LOGE(TAG, "wait network connected timeout");
		esp_restart();
	}
	
	//### ota update connect
	char otaBuffer[128];
	esp_http_client_config_t otaClientConfig = {};
	otaClientConfig.url = cfg["ota"];
	esp_http_client_handle_t otaClient = esp_http_client_init(&otaClientConfig);
	esp_ota_get_app_elf_sha256(otaBuffer, sizeof(otaBuffer));
	ESP_ERROR_CHECK(esp_http_client_set_header(otaClient, "Hash", otaBuffer));
	ESP_ERROR_CHECK(esp_http_client_open(otaClient, 0));

	//### cleanup
	#ifdef APP_NET_ETH
		ESP_ERROR_CHECK_WITHOUT_ABORT(esp_event_handler_instance_unregister(ETH_EVENT, ETHERNET_EVENT_CONNECTED,  ethConnectedHandler));
	#else
		ESP_ERROR_CHECK_WITHOUT_ABORT(esp_event_handler_instance_unregister(WIFI_EVENT, WIFI_EVENT_STA_START,     wifiScanHandler));
		ESP_ERROR_CHECK_WITHOUT_ABORT(esp_event_handler_instance_unregister(WIFI_EVENT, WIFI_EVENT_SCAN_DONE,     wifiConnectHandler));
		ESP_ERROR_CHECK_WITHOUT_ABORT(esp_event_handler_instance_unregister(WIFI_EVENT, WIFI_EVENT_STA_CONNECTED, wifiConnectedHandler));
	#endif
	vSemaphoreDelete(networkConnectedSemaphore);
	spi_flash_munmap(cfgDataHandle);

	//### ota update finish
	esp_http_client_fetch_headers(otaClient);
	if (esp_http_client_get_status_code(otaClient) == HttpStatus_Ok)
	{
		ESP_LOGI(TAG, "ota update");
		esp_ota_handle_t updateHandle;
		const esp_partition_t *updatePart = esp_ota_get_next_update_partition(NULL);
		ESP_ERROR_CHECK(esp_ota_begin(updatePart, esp_http_client_get_content_length(otaClient), &updateHandle));
		while (!esp_http_client_is_complete_data_received(otaClient)) {
			int chunkSize = esp_http_client_read(otaClient, otaBuffer, sizeof(otaBuffer));
			ESP_ERROR_CHECK(esp_ota_write(updateHandle, (const void *)otaBuffer, chunkSize));
		}
		ESP_ERROR_CHECK(esp_ota_end(updateHandle));
		ESP_ERROR_CHECK(esp_ota_set_boot_partition(updatePart));
		esp_restart();
	}
	ESP_ERROR_CHECK_WITHOUT_ABORT(esp_http_client_cleanup(otaClient));
}


extern "C" void app_main(void)
{
	main_init();
	
	ESP_LOGI(TAG, "app start");
	start();
	
	ESP_LOGI(TAG, "app loop");
	esp_log_level_set(TAG, ESP_LOG_WARN);
	
	for (TickType_t xLastWakeTime = xTaskGetTickCount();;) {
		loop();
		
		//### loop plugins
		#ifdef APP_SERIAL_LOOP
			APP_SERIAL_LOOP;
		#endif
		
		vTaskDelayUntil(&xLastWakeTime, pdMS_TO_TICKS(APP_LOOP_PERIOD));
	}
}
