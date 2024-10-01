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


import server
from shared import network


text = """\
{description}

Contact:
	{name}
	Email: {email}
	Phone: {phone}
"""


class Handler(server.RequestHandler):
	
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

		issue = await server.run_in_executor(get_issue)
		issue['Reply-To'] = self.get_body_argument("email")
		
		match self.get_query_argument('action', 'download'):
			case 'download':
				self.set_header('Content-Type',			'message/rfc822')
				self.set_header('Content-Disposition',	'attachment; filename=issue.eml')
				self.write(bytes(issue))
			case 'send':
				await server.run_in_executor(network.sendEmail, issue)



server.addAjax(__name__, Handler)
