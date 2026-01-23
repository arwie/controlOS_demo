# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations

import json
from pathlib import Path
import asyncio
from itertools import chain

from shared import tornado
from shared.tornado import RequestHandler, WebSocketHandler


cwd = Path.cwd()



class ModuleHandler(RequestHandler):

	def initialize(self):
		super().initialize()
		self.set_header('Content-Type', 'text/javascript; charset=utf-8')

	async def get(self):
		self.write(b'export default ')
		self.write(await self.export_default())

	async def export_default(self):
		return {}



_handlers = []

def handler[T:type[RequestHandler | WebSocketHandler]](handler:T) -> T:
	_handlers.append((f'/{handler.__module__}.{handler.__name__}', handler))
	return handler


def redirect(match, target):
	_handlers.append((f'/{match}', tornado.RedirectHandler, {'url':target}))



@handler
class files(ModuleHandler):
	globs = list[str]()

	@classmethod
	def glob(cls, *globs:str):
		cls.globs.extend(globs)

	async def export_default(self):
		globs = (cwd.glob(glob, recurse_symlinks=True) for glob in self.globs)
		files = set(str(path.relative_to(cwd)) for path in chain(*globs) if path.is_file() and path.exists())
		return {
			file: self.static_url(file) for file in files
		}


@handler
class setup(ModuleHandler):
	async def export_default(self):
		from shared.setup import setup
		return setup



@handler
class targets(WebSocketHandler):
	all = tornado.WebSocketConnections()
	targets = list[str]()
	
	@classmethod
	def start(cls):

		async def watchdog():
			while True:
				await asyncio.sleep(1)
				cls.all.write_message(None, send_unchanged=True)

		async def update():
			journalctl = await asyncio.create_subprocess_exec('journalctl','--follow','--output=cat','--lines=0','_PID=1', stdout=asyncio.subprocess.PIPE)
			assert journalctl.stdout is not None
			
			timeout = 0
			while True:
				try:
					line = await asyncio.wait_for(journalctl.stdout.readline(), timeout)
					if b'target' in line:
						timeout = 0.1
					continue
				except asyncio.TimeoutError:
					timeout = None
				
				systemctl  = await asyncio.create_subprocess_exec('systemctl','list-units','--no-pager','--no-legend','--plain','--type=target','--state=active', stdout=asyncio.subprocess.PIPE)
				targets,*_ = await systemctl.communicate()
				cls.targets = list(t.partition('.target')[0] for t in targets.decode().splitlines())
				
				cls.all.write_message(cls.targets)

		cls.tasks = asyncio.create_task(watchdog()), asyncio.create_task(update())

	def open(self):
		self.all.add(self)
		self.write_message(self.targets)
	
	def on_close(self):
		self.all.discard(self)

	def post(self):
		pass # connection test



class document(RequestHandler):

	importmap = dict[str,str]()
	imports = list[str]()
	stylesheets = list[str]()
	favicon: str | None = None


	_html = None

	def initialize(self):
		if document._html: return

		for mjs in cwd.rglob('*.*js', recurse_symlinks=True):
			path = str(mjs.relative_to(cwd))
			surl = self.static_url(
				str(mjs.resolve().relative_to(cwd)) if mjs.is_symlink() else path
			)
			self.importmap[f'/~/{path}'] = surl
			module = path.rpartition('.')[0].removesuffix('/index')
			self.importmap[module] = surl

		document._html = self.render_string('web.html',
			importmap=json.dumps(self.importmap, indent=2),
			imports=self.imports,
			stylesheets=self.stylesheets,
			favicon=self.favicon,
		)

		del document.importmap, document.imports, document.stylesheets, document.favicon


	def get(self):
		self.write(document._html)



def server() -> tornado.HTTPServer:

	class StaticFileHandler(tornado.StaticFileHandler):
		def validate_absolute_path(self, root, absolute_path):
			if absolute_path.endswith('.py'):
				raise tornado.HTTPError(404)
			return super().validate_absolute_path(root, absolute_path)

	targets.start()

	return tornado.HTTPServer(
		tornado.Application(
			[*_handlers, ('/.*', document)],
			static_path=cwd,
			static_url_prefix='/~/',
			static_handler_class=StaticFileHandler,
			websocket_ping_interval=10,
			compiled_template_cache=False,
			static_hash_cache=False,
		),
		max_buffer_size=128*1024*1024,
	)
