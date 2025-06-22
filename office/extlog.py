# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from tempfile import TemporaryDirectory
from asyncio import to_thread
from pathlib import Path
import web
from shared import system


extlogDir = TemporaryDirectory(prefix='office.', suffix='.extlog', dir='/var/tmp')


from diag import log

log.config.extlog = True
log.cmd = ['journalctl', f'--file={extlogDir.name}/*']



@web.handler
class journal(web.RequestHandler):

	async def put(self):
		for f in Path(extlogDir.name).glob('*'):
			f.unlink()

		await to_thread(
			system.run,
			f'set -o pipefail; xzcat | /lib/systemd/systemd-journal-remote --output={extlogDir.name}/extlog.journal -',
			input=self.request.body
		)
