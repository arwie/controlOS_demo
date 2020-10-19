#include <syswlan.h>
#include <WiFiUdp.h>



void setup() {
	while (!Serial) { ; }
	
	syswlan_begin(IPAddress(90,0,0,30));
	
	Serial.println("connected:");
	Serial.println(WiFi.SSID());
	Serial.println(WiFi.localIP());
	Serial.println(WiFi.RSSI());


	pinMode(LED_BUILTIN, OUTPUT);
}



void loop() {
	
	digitalWrite(LED_BUILTIN, HIGH);
	delay(200);
	digitalWrite(LED_BUILTIN, LOW);
	
	
	delay(1000);
	syswlan_check();
}
