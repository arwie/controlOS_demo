# SPDX-FileCopyrightText: 2025 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from collections import OrderedDict
from collections.abc import MutableMapping
from sqlite3 import connect, Connection
from pathlib import Path
import logging



# convert columns of the form 'aaa_bbb_c' to a nested dict['aaa']['bbb']['c']
def rowToData(cursor, row):
	data = {}
	for idx, col in enumerate(cursor.description):
		path = col[0].split('_')
		d = data
		for key in path[:-1]:
			d = d.setdefault(key, {})
		d[path[-1]] = row[idx]
	return data

# convert a nested dict back to columns
def dataToRow(data, prefix=''):
	row = []
	for k, v in data.items():
		column = prefix+'_'+k if prefix else k
		if isinstance(v, MutableMapping):
			row.extend(dataToRow(v, column).items())
		else:
			row.append((column, v))
	return dict(row)



class SqliteTable:
	
	def __init__(self, sqlite:Sqlite, name:str):
		self.db		= sqlite.db
		self.dbr	= sqlite.dbr
		self.schema	= sqlite.schema[name]
		self.name	= name
		self.select	= ','.join(['id','ord']+[c for c,d in self.schema.items() if not d.startswith('BLOB')])
	
	def list(self, where:dict={}, order='ord'):
		where_sql = f"WHERE {' AND '.join(f'{c}=:{c}' for c in where.keys())}" if where else ''
		return self.dbr.execute(
			f'SELECT {self.select} FROM {self.name} {where_sql} ORDER BY {order}',
			where
		).fetchall()
	
	def load(self, id, select=None):
		return self.dbr.execute(
			f'SELECT {select if select else self.select} FROM {self.name} WHERE id=:id',
			{'id':id}
		).fetchone()
	
	def create(self, data={}):
		if data:
			data = dataToRow(data)
			keys = set(self.schema.keys()) & set(data.keys())
			sql = f"({','.join(c for c in keys)}) VALUES ({','.join(':'+c for c in keys)})"
		else:
			sql = 'DEFAULT VALUES'
		return self.db.execute(f'INSERT INTO {self.name} {sql}', data).lastrowid
	
	def copy(self, id):
		cols = ','.join(self.schema.keys())
		return self.db.execute(
			f'INSERT INTO {self.name} ({cols}) SELECT {cols} FROM {self.name} WHERE id=:id',
			{'id':id}
		).lastrowid
	
	def save(self, id, data):
		data = dataToRow(data)
		data['id'] = id
		keys = set(self.schema.keys()) & set(data.keys())
		cols = ','.join(f'{c}=:{c}' for c in keys)
		self.db.execute(
			f'UPDATE {self.name} SET {cols} WHERE id=:id',
			data
		)
	
	def swap(self, id, sw):
		if id == sw: return
		idOrd = self.db.execute(f'SELECT ord FROM {self.name} WHERE id=:id', {'id':id}).fetchone()['ord']
		swOrd = self.db.execute(f'SELECT ord FROM {self.name} WHERE id=:sw', {'sw':sw}).fetchone()['ord']
		self.db.execute(f'UPDATE {self.name} SET ord=:swOrd WHERE id=:id', {'swOrd':swOrd, 'id':id})
		self.db.execute(f'UPDATE {self.name} SET ord=:idOrd WHERE id=:sw', {'idOrd':idOrd, 'sw':sw})
	
	def remove(self, id):
		self.db.execute(f'DELETE FROM {self.name} WHERE id=:id', {'id':id})



class Sqlite:
	
	def __init__(self, path:str, schemaVersion:int, definition:list[tuple[str, dict[str, str]]|tuple[str, dict[str, str], str]]):
		self.schema = OrderedDict([(t[0],t[1]) for t in definition])
		
		def dbFile(version):
			return Path(f'{path}.{version}.sqlite')
		
		self.file = dbFile(schemaVersion)
		self.db = connect(self.file)
		self.db.row_factory = rowToData
		self.db.execute('PRAGMA synchronous = OFF;')
		
		if not self.db.execute('SELECT * FROM sqlite_master;').fetchone():	# db empty
			logging.info(__name__+": creating tables")
			with self.db:
				self.create(definition)
				self.db.execute('PRAGMA user_version = {};'.format(schemaVersion))
				migrated = False
				for oldVersion in reversed(range(1, schemaVersion)):
					oldDbFile = dbFile(oldVersion)
					if oldDbFile.is_file():
						if not migrated:
							logging.info(__name__+": migrating from old database {}".format(oldDbFile))
							migrated = True
							try:
								oldDb = connect('file:{}?mode=ro'.format(oldDbFile), uri=True)
								oldDb.row_factory = rowToData
								self.migrate(oldDb, oldVersion)
							except:
								logging.exception(__name__+": failed to migrate from old database")
						else:
							oldDbFile.unlink()
				if not migrated:
					self.populate()
		
		self.db.execute('PRAGMA foreign_keys = ON;')	#check foreign keys after migrating
		
		self.dbr = connect(self.file, check_same_thread=False)
		self.dbr.execute('PRAGMA query_only = ON;')
		self.dbr.row_factory = rowToData
	
	
	def create(self, definition):
		for table in definition:
			columns = ','.join(f'{c} {d}' for c,d in table[1].items()),
			constraint = f',{table[2]}' if len(table)>=3 else ''
			self.db.execute(
				f'CREATE TABLE IF NOT EXISTS {table[0]} (id INTEGER PRIMARY KEY AUTOINCREMENT, ord INTEGER, {columns} {constraint})'
			)
			self.db.execute(
				f'CREATE TRIGGER {table[0]}_ord AFTER INSERT ON {table[0]} FOR EACH ROW WHEN NEW.ord IS NULL BEGIN UPDATE {table[0]} SET ord = NEW.rowid WHERE rowid = NEW.rowid; END;'
			)
	
	
	def migrate(self, oldDb:Connection, oldVersion:int):
		oldTables = [t['name'] for t in   oldDb.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
		newTables = [t['name'] for t in self.db.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
		tables    = [t for t in newTables if t in oldTables]
		
		for table in tables:
			oldColumns = [d[0] for d in   oldDb.execute(f"SELECT * FROM {table}").description]
			newColumns = [d[0] for d in self.db.execute(f"SELECT * FROM {table}").description]
			columns    = [c for c in newColumns if c in oldColumns]
			for oldRow in oldDb.execute(f"SELECT * FROM {table}").fetchall():
				self.db.execute(
					f"INSERT INTO {table} ({','.join(columns)}) VALUES ({','.join([':'+c for c in columns])})",
					dataToRow(oldRow)
				)
	
	
	def populate(self):
		pass
