#include <common.h>
#include <syswlan.h>
#include <update.h>
#include <websocket.h>
#include <Arduino_LSM6DS3.h>


#define version			1

#define xInput			4
#define yInput			2
#define analogDamping	60


float xCenter, yCenter;

WebsocketsClientJson wsClient;



void setup() {
	pinMode(LED_BUILTIN, OUTPUT);
	digitalWrite(LED_BUILTIN, HIGH);
	
	while (!Serial) { ; }
	
	syswlan_begin(IPAddress(90,0,0,31));
	update(version);
	
	IMU.begin();
	
	joystickCenter();
	Serial.print(xCenter); Serial.print(" # "); Serial.println(yCenter);
	
	wsClient.begin("90.0.0.1", 55001);
	
	digitalWrite(LED_BUILTIN, LOW);
}



void loop() {
	static bool idle = true;
	//calibrateJoystick();	return;
	//calibrateIMU();		return;
	
	auto x = +joystickDirection(analogReadFiltered<xInput, analogDamping>(), 465, xCenter, 727);
	auto y = -joystickDirection(analogReadFiltered<yInput, analogDamping>(), 342, yCenter, 685);
	Serial.print(x); Serial.print(" / "); Serial.println(y);
	
	StaticJsonDocument<256> data;
	
	if (abs(x)>0 || abs(y)>0) {
		data["abs"]			= false;
		data["dir"]["x"]	= 0;
		data["dir"]["y"]	= 0;
		data["dir"]["z"]	= 0;
		data["dir"]["r"]	= 0;
		
		if (abs(x)>abs(y)) {
			data["dir"]["x"]	= x>0 ? 1 : -1;
			data["speed"]		= 10*abs(x);
		} else {
			data["dir"]["y"]	= y>0 ? 1 : -1;
			data["speed"]		= 10*abs(y);
		}
		
		sendCmd(data, 1);
		idle = false;
	} else {
		if (!idle) {
			sendCmd(data, 0);
			idle = true;
		}
	}
	
	
	wsClient.loop();
	delay(25);
	digitalWrite(LED_BUILTIN, LOW);
	delay(25);
}


void sendCmd(JsonDocument& data, const int cmd) {
	data["cmd"] = cmd;
	wsClient.sendJson(data);
	digitalWrite(LED_BUILTIN, HIGH);
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
	float x, y, z;
	
	IMU.readAcceleration(x, y, z);
	
	Serial.print(x); Serial.print(" / "); Serial.print(y); Serial.print(" / "); Serial.println(z);
	delay(500);
}
