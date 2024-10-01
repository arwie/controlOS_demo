# Copyright (c) 2024 Artur Wiebe <artur@4wiebe.de>
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


from collections.abc import Callable
from email.mime.multipart	import MIMEMultipart
from email.mime.text		import MIMEText
from email.mime.application	import MIMEApplication
from shared.utils import import_all_in_package
import json
from textwrap import indent
from shared.conf import Conf
from shared import system
from shared import network
import logging



def get_version():
	with open('/version') as f:
		version = json.load(f)
	return f"{version['name'] or '-'} ({version['id']})"

def get_backup():
	return system.run(['backup'], True)

def get_network():
	return network.status().encode()

def get_journal():
	return system.run('set -o pipefail; journalctl --merge --no-pager --output=export --since=-28days | xz -T0', True)

def get_short_log():
	return system.run(['journalctl','--merge','--no-pager','--quiet','--output=short','--priority=warning','--reverse','--lines=50'], True, text=True)


_attachments: dict[str, Callable[[], str | bytes]] = {
	'Backup.gpg':	get_backup,
	'Network':		get_network,
	'Journal.xz':	get_journal,
}

def add_attachment(name:str, contents:Callable[[], str | bytes]):
	_attachments[name] = contents



import_all_in_package(__file__, __name__)


add_attachment('Version',	get_version)
add_attachment('Short Log',	get_short_log)



class Issue(MIMEMultipart):
	def __init__(self, text):
		super().__init__()

		conf = Conf('/etc/issue.conf')
		self['To']		= conf.get('issue', 'to')
		self['Subject']	= conf.get('issue', 'subject', fallback='issue report')
		
		self.attach(MIMEText(text))

		for name, contents in _attachments.items():
			try:
				contents = contents()
			except Exception as e:
				logging.exception(e)
				contents = str(e)

			self.attach(
				MIMEText(name + ':\n' + indent(contents, '\t'))
				if isinstance(contents, str) else
				MIMEApplication(contents, name=name)
			)
