// Copyright (c) 2022 Artur Wiebe <artur@4wiebe.de>
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


class UdpSender
{
public:
	void init(const char* receiverAddr, const int receiverPort)
	{
		addr.sin_addr.s_addr = inet_addr(receiverAddr);
		addr.sin_port = htons(receiverPort);
		addr.sin_family = AF_INET;
		
		sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
		if (sock < 0)
			ESP_LOGE(TAG, "UdpSender:init > errno %d", errno);
	}
	
	void send(const JsonDocument& data)
	{
		char msg[512];
		auto msgLen = serializeJson(data, msg, sizeof(msg));
		ESP_LOGI(TAG, "UdpSender:sending > %s", msg);
		if (sendto(sock, msg, msgLen, 0, (struct sockaddr *)&addr, sizeof(addr)) < 0)
			ESP_LOGE(TAG, "UdpSender:send > errno %d", errno);
	}
	
private:
	struct sockaddr_in addr;
	int sock;
};



template <size_t jsonDocSize>
class UdpSlave
{
public:
	UdpSlave(const int port) : port(port) {}
	
	void start(function<void(JsonDocument& msg)> onMessage, int timeoutMs=1000, function<void(void)> onDisconnect=NULL)
	{
		this->onMessage = onMessage;
		
		sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
		if (sock < 0)
			ESP_LOGE(TAG, "UdpSlave:init:socket > errno %d", errno);
		
		addr.sin_family = AF_INET;
		addr.sin_addr.s_addr = htonl(INADDR_ANY);
		addr.sin_port = htons(port);
		
		if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0)
			ESP_LOGE(TAG, "UdpSlave:init:bind > errno %d", errno);
		
		this->onDisconnect = onDisconnect;
		struct timeval to;
		to.tv_sec  = 0;
		to.tv_usec = 1000*timeoutMs;
		if (setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &to, sizeof(to)) < 0)
			ESP_LOGE(TAG, "UdpSlave:setsockopt:timeout > errno %d", errno);
		
		xTaskCreate(UdpSlave::task, "UdpSlave", 4096, this, 5, NULL);
	}
	
	bool connected = false;
	
private:
	static void task(void *arg)
	{
		auto slave = (UdpSlave*)arg;
		for (;;) {
			if (slave->receive()) {
				slave->connected = true;
				slave->onMessage(slave->msg);
				slave->send();
			} else {
				if (slave->connected) {
					slave->connected = false;
					ESP_LOGW(TAG, "UdpSlave > disconnected");
					if(slave->onDisconnect)
						slave->onDisconnect();
				}
			}
		}
	}
	
	bool receive()
	{
		char buffer[jsonDocSize];
		socklen_t socklen = sizeof(addr);
		auto len = recvfrom(sock, buffer, sizeof(buffer), 0, (struct sockaddr *)&addr, &socklen);
		if (len < 0) {
			switch (errno) {
				case ETIMEDOUT:
				case EAGAIN:
					break;
				default:
					ESP_LOGE(TAG, "UdpSlave:receive > errno %d", errno);
			}
			return false;
		}
		ESP_LOGI(TAG, "UdpSlave:receive > %.*s", len,buffer);
		
		deserializeJson(msg, (const char*)buffer, len);
		return true;
	}
	
	void send()
	{
		char buffer[jsonDocSize];
		auto len = serializeJson(msg, buffer, sizeof(buffer));
		ESP_LOGI(TAG, "UdpSlave:send > %.*s", len,buffer);
		
		if (sendto(sock, buffer, len, 0, (struct sockaddr *)&addr, sizeof(addr)) < 0)
			ESP_LOGE(TAG, "UdpSlave:send > errno %d", errno);
	}
	
	int port;
	int sock;
	struct sockaddr_in addr;
	StaticJsonDocument<jsonDocSize> msg;
	function<void(JsonDocument& msg)> onMessage;
	function<void(void)> onDisconnect;
};
