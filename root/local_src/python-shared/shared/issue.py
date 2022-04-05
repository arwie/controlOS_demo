# Copyright (c) 2021 Artur Wiebe <artur@4wiebe.de>
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


from email.mime.multipart	import MIMEMultipart
from email.mime.text		import MIMEText
from email.mime.application	import MIMEApplication
from shared.conf import Conf
from shared import system
import logging, pathlib



def getVersion():
	return pathlib.Path('/version').read_text()

def getBackup():
	return system.run(['backup'], True)

def getNetwork():
	from shared import network
	return network.status()

def getJournal():
	return system.run('set -o pipefail; journalctl --merge --no-pager --output=export --since=-28days | xz -T0', True)

def getShortLog():
	return system.run(['journalctl','--merge','--no-pager','--quiet','--output=short','--priority=notice','--reverse','--lines=100'], True)


attachments = {
	'version':		getVersion,
	'backup.gpg':	getBackup,
	'network':		getNetwork,
	'journal.xz':	getJournal,
	'shortLog':		getShortLog,
}

try:
	from shared import issue_app
except ImportError: pass


class Issue(MIMEMultipart):
	def __init__(self, text):
		super().__init__()
		conf = Conf('/etc/issue.conf')
		
		self.attach(MIMEText(text))
		self['To']		= conf.get('issue', 'to')
		self['Subject']	= conf.get('issue', 'subject', fallback='issue report')
		
		for name,contents in attachments.items():
			if callable(contents):
				try:
					contents = contents()
				except Exception as e:
					logging.exception(e)
					contents = str(e)
			self.attach(MIMEApplication(contents, name=name))
