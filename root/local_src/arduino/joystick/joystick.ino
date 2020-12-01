#include <common.h>
#include <syswlan.h>
#include <update.h>
#include <websocket.h>
#include <Arduino_LSM6DS3.h>


#define version			1

#define xInput			4
#define yInput			2
#define analogDamping	60


WebsocketsClientJson wsClient;

float xCenter, yCenter;
float a, b, c;
float x, y;
bool gripped;



void setup() {
	pinMode(LED_BUILTIN, OUTPUT);
	digitalWrite(LED_BUILTIN, HIGH);
	
	for (float a,b,c=1.0; !Serial && c>0.5; IMU.readAcceleration(a,b,c)) { IMU.begin(); }
	
	syswlan_begin(IPAddress(90,0,0,31));
	update(version);
	
	joystickCenter();
	Serial.print(xCenter); Serial.print(" # "); Serial.println(yCenter);
	
	wsClient.begin("90.0.0.1", 55001);
	wsClient.onMessageJson<256>(handleInfo);
	
	digitalWrite(LED_BUILTIN, LOW);
}



void sendCmd(JsonDocument& data, const int cmd = 0) {
	data["cmd"] = cmd;
	wsClient.sendJson(data);
	digitalWrite(LED_BUILTIN, HIGH);
}

void handleInfo(JsonDocument& data)
{
	gripped = data["gripped"];
}


bool controlDelta(JsonDocument& data) {
	static int tilted = 0;
	
	if (c < -0.7) {
		tilted = 0;
	} else {
		int tilt = abs(a)>abs(b) ? 1: -1;
		if (!tilted) {
			tilted = tilt;
		}
		static bool gripSent = false;
		if (tilted!=tilt) {
			if (!gripSent) {
				data["grip"] = !gripped;
				sendCmd(data, -2);
				gripSent = true;
			}
		} else {
			gripSent = false;
		}
	}
	
	if (x==0 && y==0)
		return true;
	
	data["abs"]			= false;
	data["dir"]["x"]	= 0;
	data["dir"]["y"]	= 0;
	data["dir"]["z"]	= 0;
	data["dir"]["r"]	= 0;
	
	switch (tilted) {
		case 0:
			if (abs(x)>abs(y)) {
				data["dir"]["x"]	= x>0 ? 1 : -1;
				data["speed"]		= 10*abs(x);
			} else {
				data["dir"]["y"]	= y>0 ? 1 : -1;
				data["speed"]		= 10*abs(y);
			}
			break;
		case 1:
			data["dir"]["z"]	= (a<0 && x<0) || (a>0 && x>0) ? 1 : -1;
			data["speed"]		= 10*abs(x);
			break;
		case -1:
			data["dir"]["z"]	= (b<0 && y<0) || (b>0 && y>0) ? 1 : -1;
			data["speed"]		= 10*abs(y);
			break;
	}
	
	sendCmd(data, 1);
	return false;
}


bool controlConv(JsonDocument& data) {
	if (y==0)
		return true;
	
	data["speed"]		= 10*abs(y);
	data["dir"]["x"]	= y<0 ? 1 : -1;
	data["dir"]["y"]	= 0;
	data["dir"]["z"]	= 0;
	data["dir"]["r"]	= 0;
	
	sendCmd(data, 11);
	return false;
}



void loop() {
	//calibrateJoystick();	return;
	//calibrateIMU();		return;
	
	x = +joystickDirection(analogReadFiltered<xInput, analogDamping>(), 465, xCenter, 727);
	y = -joystickDirection(analogReadFiltered<yInput, analogDamping>(), 342, yCenter, 685);
	//Serial.print(x); Serial.print(" / "); Serial.println(y);
	
	if (x==0 && y==0) {
		IMU.begin();
		IMU.readAcceleration(a, b, c);
		//Serial.print(a); Serial.print(" / "); Serial.print(b); Serial.print(" / "); Serial.println(c);
	}
	
	StaticJsonDocument<256> data;
	static int select = 1;
	bool stop = true;
	
	if (select) {
		if (c > 0.8) {
			select = 0;
			Serial.print("Select: ");
		}
	} else {
		if (a < -0.8) {
			select = 1;
			Serial.println("DELTA");
		}
		if (a > +0.8) {
			select = 11;
			Serial.println("CONVEYOR");
		}
	}
	
	switch(select) {
		case 1:
			stop = controlDelta(data);
			break;
		case 11:
			stop = controlConv(data);
			break;
	}
	
	static bool stopped = true;
	if (stop) {
		if (!stopped) {
			sendCmd(data);
			stopped = true;
		}
	} else {
		stopped = false;
	}
	
	wsClient.loop();
	delay(25);
	digitalWrite(LED_BUILTIN, LOW);
	delay(25);
}


void joystickCenter() {
	const int N = 1000;
	xCenter = yCenter = 0.0;
	for (int n=N; n; --n) {
		xCenter += analogRead(xInput);
		yCenter += analogRead(yInput);
		delay(1);
	}
	xCenter /= N;
	yCenter /= N;
}

float joystickDirection(float v, const int vMin, const float vCenter, const int vMax) {
	v = (v-vCenter) / (v>vCenter ? vMax-vCenter : vCenter-vMin);
	if (v < -1.0)
		v = -1.0;
	if (v > +1.0)
		v = +1.0;
	if (abs(v) < 0.10)
		v = 0.0;
	return v*abs(v);
}


template <int input, int weight>
float analogReadFiltered() {
	static float value = analogRead(input);
	value = (weight/100.0)*value + ((100-weight)/100.0)*analogRead(input);
	return value;
}


void calibrateJoystick() {
	static int maxX = 0,	maxY = 0;
	static int minX = 1024,	minY = 1024;
	
	int nowX = analogReadFiltered<xInput, analogDamping>();
	int nowY = analogReadFiltered<yInput, analogDamping>();
	
	minX = std::min(nowX, minX); maxX = std::max(nowX, maxX);
	minY = std::min(nowY, minY); maxY = std::max(nowY, maxY);
	
	Serial.print("rawX: "); Serial.print(minX); Serial.print("/"); Serial.print(maxX); Serial.print(" - "); Serial.println(nowX);
	Serial.print("rawY: "); Serial.print(minY); Serial.print("/"); Serial.print(maxY); Serial.print(" - "); Serial.println(nowY);
	Serial.println();
	delay(500);
}


void calibrateIMU() {
	float a, b, c;
	
	IMU.begin();
	IMU.readAcceleration(a, b, c);
	Serial.print(a); Serial.print(" / "); Serial.print(b); Serial.print(" / "); Serial.println(c);
	
	delay(500);
}
