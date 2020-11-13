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


#include <ArduinoOTA.h>
#include <ArduinoHttpClient.h>


void update(const int version = 0)
{
	StaticJsonDocument<256> update;
	deserializeJson(update, "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU");
	
	WiFiClient tcp;
	HttpClient client(tcp, update["sys"].as<const char*>(), 8101);
	
	client.beginRequest();
	client.get(update["name"].as<const char*>());
	client.sendHeader("Content-MD5", update["md5"].as<const char*>());
	client.sendHeader("Content-Version", version);
	client.endRequest();
	
	if (client.responseStatusCode() != 200) {	//200:OK
		client.stop();
		return;
	}
	
	long length = client.contentLength();
	
	if (!InternalStorage.open(length)) {
		client.stop();
		Serial.println("update is too large");
		return;
	}
	
	for (byte b; length > 0; --length) {
		if (!client.readBytes(&b, 1))
			resetError("update download timeout");
		InternalStorage.write(b);
	}
	
	InternalStorage.close();
	client.stop();
	
	InternalStorage.apply();
}
