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


#define _WEBSOCKETS_LOGLEVEL_			1		// 0:DISABLED, 1:ERROR, 2:WARN, 3:INFO, 4:DEBUG
#define WEBSOCKETS_USE_WIFININA			true
#define WEBSOCKETS_WIFININA_USE_SAMD	true
#include <WebSockets2_Generic.h>


class WebsocketsClientJson : public websockets2_generic::WebsocketsClient
{
public:
	
	void begin(const char* host, int port, const char* path = "/")
	{
		if (!connect(host, port, path))
			resetError("websocket connecting failed");
	}
	
	bool sendJson(const JsonDocument& data)
	{
		String msg;
		serializeJson(data, msg);
		Serial.print("sending:"); Serial.println(msg);
		return send(msg);
	}
	
	template <size_t jsonCapacity>
	void onMessageJson(std::function<void(JsonDocument& data)> callback)
	{
		onMessage([callback](websockets2_generic::WebsocketsMessage msg)
		{
			Serial.print("received:"); Serial.println(msg.data());
			StaticJsonDocument<jsonCapacity> data;
			deserializeJson(data, msg.data());
			callback(data);
		});
	}
	
	void loop()
	{
		poll();
		if (!available())
			resetError("websocket disconnected");
	}
};
