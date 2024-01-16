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


#include <driver/uart.h>
#include <esp_vfs_dev.h>


void serial_receive(char cmd);

void serial_loop()
{
	char cmd;
	if (uart_read_bytes(UART_NUM_0, &cmd, 1, 0) > 0) {
		ESP_LOGI(TAG, "serial_receive: cmd > %i (%c)", cmd, cmd);
		switch (cmd) {
			case 27:	//ESC
				esp_log_level_set(TAG, ESP_LOG_INFO);
				break;
			default:
				serial_receive(cmd);
		}
		uart_flush_input(UART_NUM_0);
	}
}
#define APP_SERIAL_LOOP		serial_loop()


void serial_init()
{
	ESP_ERROR_CHECK(uart_driver_install(UART_NUM_0, 2*UART_FIFO_LEN, 0, 0, NULL, 0));
	esp_vfs_dev_uart_use_driver(UART_NUM_0);
}
#define APP_SERIAL_INIT		serial_init()
