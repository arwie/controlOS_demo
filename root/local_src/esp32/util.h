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


#include <driver/gpio.h>

#include <functional>


#define MS_MIN_TICKS(ms) ( 1 + (((ms) + ((portTICK_PERIOD_MS) - 1)) / (portTICK_PERIOD_MS)) )	//compute ticks to sleep at least ms milliseconds



template<typename T> int sgn(T val) {
	return (T(0) < val) - (val < T(0));
}


void gpio_init_pin_output(gpio_num_t gpio_num) {
	gpio_reset_pin(gpio_num);
	gpio_set_direction(gpio_num, GPIO_MODE_OUTPUT);
}


#ifdef APP_NET_ETH

#else //wifi

int8_t wifi_signal() {
	wifi_ap_record_t ap = {};
	ESP_ERROR_CHECK_WITHOUT_ABORT(esp_wifi_sta_get_ap_info(&ap));
	return ap.rssi;
}

#endif //APP_NET_ETH
