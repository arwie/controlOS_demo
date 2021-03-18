# Copyright (c) 2017 Artur Wiebe <artur@4wiebe.de>
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
import subprocess
from tornado import template
from datetime import datetime
from shared import network
from shared.conf import Conf
import logging, json



def renderLogHtml(data):
	
	def processMessage(msg):
		msg['_SOURCE_REALTIME_TIMESTAMP'] = datetime.utcfromtimestamp(int(msg.get('_SOURCE_REALTIME_TIMESTAMP' if '_SOURCE_REALTIME_TIMESTAMP' in msg else '__REALTIME_TIMESTAMP', 0))/1000000).strftime('%d.%m.%Y, %H:%M:%S')
		msg['PRIORITY'] = int(msg.get('PRIORITY', 6))
		msg = {k:v for k,v in msg.items() if not k.startswith('__')}
		return msg
	
	return template.Template("""\
		<!DOCTYPE html>
		<html>
		<head>
			<meta charset="utf-8"/>
			<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
			<style>{{bootstrapCss}}</style>
		</head>
		<script>
			function toggleDisplay(div) { div.style.display = div.style.display == "none" ? "block" : "none"; }
		</script>
		<body>
			<table class="table table-sm table-hover">
			<tbody>
			{% for msg in messages %}
				<tr class="{{ {2:'table-danger', 3:'table-danger', 4:'table-warning', 5:'table-info'}.get(msg['PRIORITY']) }}">
					<td>{{msg.get('_SOURCE_REALTIME_TIMESTAMP')}}</td>
					<td>{{ {0:'Emergency', 1:'Alert', 2:'Critical', 3:'Error', 4:'Warning', 5:'Notice', 6:'Info', 7:'Debug'}.get(msg['PRIORITY']) }}</td>
					<td>{{msg.get('_HOSTNAME')}}</td>
					<td>{{msg.get('SYSLOG_IDENTIFIER')}}</td>
					<td width="70%">
						<a onclick="toggleDisplay(this.nextElementSibling);return false" href="#"><strong style="white-space:pre-line">{{msg.get('MESSAGE')}}</strong></a>
						<div style="display:none">
							<p></p>
							<table class="table table-sm">
							<tbody>
							{% for key,value in msg.items() %}
								<tr>
									<td>{{key}}</td>
									<td style="white-space:pre-line">{{value}}</td>
								</tr>
							{% end %}
							</tbody>
							</table>
						</div>
					</td>
				</tr>
			{% end %}
			</tbody>
			</table>
		</body>
		</html>
		""").generate(
				bootstrapCss	= open('/usr/lib/gui/static/bootstrap.css').read(),
				messages		= [ processMessage(json.loads(l.decode())) for l in data.splitlines() ],
			)



class Issue(MIMEMultipart):
	
	def __init__(self, text):
		super().__init__()
		conf = Conf('/etc/issue.conf')
		
		self.attach(MIMEText(text))
		self['To']		= conf.get('issue', 'to')
		self['Subject']	= conf.get('issue', 'subject', fallback='issue report')
		
		# attach version
		try:
			self.attach(MIMEApplication(
				open('/version', encoding='utf8').read(),
				name='version'
			))
		except: pass
		
		# attach backup
		self.attach(MIMEApplication(
			subprocess.run(['backup'], stdout=subprocess.PIPE).stdout,
			name='backup.txz'
		))
		
		# attach full journal export
		self.attach(MIMEApplication(
			subprocess.run('journalctl --merge --no-pager --output=export --since=-28days | xz -T0', shell=True, stdout=subprocess.PIPE).stdout,
			name='journal.xz'
		))
		
		# attach rendered journal html
		try:
			self.attach(MIMEApplication(
				renderLogHtml(subprocess.run(['/usr/bin/journalctl', '--merge', '--no-pager', '--output=json', '--all', '--priority=notice', '--lines=300', '--until=now', '--reverse'], stdout=subprocess.PIPE).stdout),
				name='log.html'
			))
		except Exception as e:
			logging.error(e)
		
		# attach network status
		self.attach(MIMEApplication(
			network.status(),
			name='network.txt'
		))

