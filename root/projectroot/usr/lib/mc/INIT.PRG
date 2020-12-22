<?# Copyright (c) 2019 Artur Wiebe <artur@4wiebe.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
?>


dim shared logErrorHistory as long


program continue
	call logSystemStart

	onSystemError
<?
		foreach (get('libs')['system'] as $l)
			if ($l['systemError'])
				foreach ($l['systemError'] as $e) {
					lll("catch {$e}");
					llll("call {$l['name']}_systemError");
				}
?>
		catch 19004	'ignore drive errors of unattached axes
		catch else
			call log_message(log_prioError, system.error, "init", "onSystemError")
			call com_putLong("/error", system.errornumber)
			call log_send
			logErrorHistory = true
	end onSystemError


	call init_init
	call init_start
	call system_init
	call system_start

	while not init_wait(1000)
		if logErrorHistory then
			logErrorHistory = false
			call log_message(log_prioNotice, "mc error history", "init", "errorhistory")
			call com_putString("/errorhistory", vesexecute("?errorhistorydelta"))
			call log_send
		end if
	end while

	call system_stopTimeout(10000)
	call init_stop


	call logSystemStop
	call log_waitDrain
	call log_stop
	call state_stop

	call dropString(sh("reboot"))
terminate program



sub logSystemStart
	call log_message(log_prioNotice, "mc system start", "init", "start")
	call com_putString("/system", vesexecute("?system.information"))
	call com_putString("/errorhistory", vesexecute("?errorhistorydelta"))
	call com_putString("/version", version)
	call com_putString("/sn",  system.serialNumber)
	call com_putString("/uac", system.userAuthorizationCode)
	call log_send
end sub


sub logSystemStop
	call log_message(log_prioNotice, "mc system stop", "init", "stop")
	call com_putString("/errorhistory", vesexecute("?errorhistorydelta"))
	call log_send
end sub
