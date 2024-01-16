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

#ifndef ANALOG_H_
#define ANALOG_H_


#include <esp_adc_cal.h>


static esp_adc_cal_characteristics_t analog_characteristics;


int analog_voltage(int channel, int samples=10)
{
	uint32_t raw = 0;
	for (int s=0; s<samples; ++s)
		raw += adc1_get_raw((adc1_channel_t)channel);
	raw /= samples;
	return esp_adc_cal_raw_to_voltage(raw, &analog_characteristics);
}


void analog_init()
{
	for (int ch=0; ch<8; ++ch)
		ESP_ERROR_CHECK(adc1_config_channel_atten((adc1_channel_t)ch, ADC_ATTEN_DB_11));
	ESP_ERROR_CHECK(adc1_config_width(ADC_WIDTH_BIT_12));
	esp_adc_cal_characterize(ADC_UNIT_1, ADC_ATTEN_DB_11, ADC_WIDTH_BIT_12, 0, &analog_characteristics);
}
#define APP_ANALOG_INIT		analog_init()


#endif //ANALOG_H_
