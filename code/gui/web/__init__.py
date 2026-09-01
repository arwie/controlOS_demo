# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import Callable
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
	_globs = list[str]()

	@classmethod
	def glob(cls, *globs:str):
		cls._globs.extend(globs)

	async def export_default(self):
		globs = (cwd.glob(glob, recurse_symlinks=True) for glob in self._globs)
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
class site(WebSocketHandler):
	_show = dict[str, Callable]()

	@classmethod
	def show(cls, cmp:str, guard:Callable):
		cls._show[cmp] = guard

	async def update(self):
		while True:
			await asyncio.sleep(0.5)
			if not await self.write_message([
				cmp for cmp, guard in self._show.items() if guard()
			]):
				await self.write_message(bytes(), skip_unchanged=False)

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
