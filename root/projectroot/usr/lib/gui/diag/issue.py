# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

import web
from asyncio import to_thread
from shared import network


web.document.imports.append('diag/issue')


text = """\
{description}

Contact:
	{name}
	Email: {email}
	Phone: {phone}
"""


@web.handler
class report(web.RequestHandler):
	
	def get(self):
		self.write({
			'smtpEnabled': network.smtpEnabled()
		})


	async def post(self):

		def get_issue():
			from shared.issue import Issue
			return Issue(text.format(
				description	= self.get_body_argument("description"),
				name		= self.get_body_argument("name"),
				email		= self.get_body_argument("email"),
				phone		= self.get_body_argument("phone"),
			))

		issue = await to_thread(get_issue)
		issue['Reply-To'] = self.get_body_argument("email") #type:ignore
		
		match self.get_query_argument('action', 'download'):
			case 'download':
				self.set_header('Content-Type',			'message/rfc822')
				self.set_header('Content-Disposition',	'attachment; filename=issue.eml')
				self.write(bytes(issue))
			case 'send':
				await to_thread(network.sendEmail, issue)
