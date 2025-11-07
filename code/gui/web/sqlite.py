# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:
	from shared.sqlite import SqliteTable

import web
from inspect import isawaitable



class TableHandler[T:SqliteTable](web.RequestHandler):
	table: T

	async def get(self):
		result = getattr(self, f'get_{self.get_query_argument("action", "list")}')()
		if isawaitable(result):
			result = await result
		if result is not None:
			self.write(result)
	
	async def post(self):
		with self.table.db:
			result = getattr(self, f'post_{self.get_query_argument("action")}')()
			if isawaitable(result):
				result = await result
			if result is not None:
				self.write(result)
	
	
	def get_list(self):
		return self.table.list()
	
	def get_load(self):
		return self.table.load(self.get_query_argument('id'))
	
	
	def post_create(self):
		return {'id': self.table.create()}
	
	def post_copy(self):
		return {'id': self.table.copy(self.get_query_argument('id'))}
	
	def post_remove(self):
		self.table.remove(self.get_query_argument('id'))
	
	def post_swap(self):
		self.table.swap(self.get_query_argument('id'), self.get_query_argument('swap'))
	
	def post_save(self):
		self.table.save(self.get_query_argument('id'), self.read_json())
