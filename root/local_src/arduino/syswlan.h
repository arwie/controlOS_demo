// Copyright (c) 2020 Artur Wiebe <artur@4wiebe.de>
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


#include <WiFiNINA.h>
#include <ArduinoJson.h>
#include <Sodaq_wdt.h>



void syswlan_check()
{
	if (WiFi.status() != WL_CONNECTED) {
		sodaq_wdt_enable(WDT_PERIOD_1DIV64);	//reset via watchdog
		delay(1000);
	}
}


void syswlan_begin(const IPAddress& ip)
{
	StaticJsonDocument<256> login;
	deserializeJson(login, F("WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"));
	
	int nets = WiFi.scanNetworks();
	for (int net=0; net<nets; ++net)
	{
		byte bssid[6];
		WiFi.BSSID(net, bssid);
		
		for (int i=0; i<6; ++i) {
			if (bssid[5-i] != login["bssid"][i])
				goto continueNets;
		}
		
		WiFi.config(ip);
		WiFi.begin(WiFi.SSID(net), login["psk"]);
		
		break;
		continueNets:;
	}
	syswlan_check();
}
