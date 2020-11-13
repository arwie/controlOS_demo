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


// BUGFIX: arduino.h falsly defines max and min which breaks compiling string.h
#undef max
#undef min

#include <ArduinoJson.h>
#include <ArduinoLowPower.h>
#include <Sodaq_wdt.h>



void reset()
{
	sodaq_wdt_enable(WDT_PERIOD_1DIV64);	//reset via watchdog
	delay(1000);
}

void resetError(const char *msg)
{
	Serial.print("ERROR: "); Serial.println(msg);
	reset();
}

void poweroffError(const char *msg)
{
	Serial.print("ERROR: "); Serial.println(msg);
	LowPower.deepSleep();
}


void debugWaitSerial()
{
	while (!Serial) { ; }
}


bool blinkHerz(float herz)
{
	int wavelength = 1000.0 / herz;
	return (millis() % wavelength) < (wavelength / 2);
}
