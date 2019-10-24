# Copyright (c) 2018 Artur Wiebe <artur@4wiebe.de>
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


import sqlite3, os, json, collections, logging



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
		if isinstance(v, collections.MutableMapping):
			row.extend(dataToRow(v, column).items())
		else:
			row.append((column, v))
	return dict(row)



class Table:
	
	def __init__(self, sqlite, table):
		self.db		= sqlite.db
		self.schema	= sqlite.schema[table]
		self.table	= table
	
	def list(self, where={}, order='ord'):
		return self.db.execute('SELECT * FROM {0.table} {where} ORDER BY {order}'.format(self,
					where = '' if not where else 'WHERE {}'.format(' AND '.join([c+'=:'+c for c in where.keys()])),
					order = order
				), where).fetchall()
	
	def load(self, id):
		return self.db.execute('SELECT * FROM {0.table} WHERE id=:id'.format(self), {'id':id}).fetchone()
	
	def create(self, data=None):
		if data:
			data = dataToRow(data)
			keys = set(self.schema.keys()) & set(data.keys())
			return self.db.execute('INSERT INTO {0.table} ({cols}) VALUES ({vals})'.format(self,
						cols = ','.join([c for c in keys]),
						vals = ','.join([':'+c for c in keys])
					), data).lastrowid
		else:
			return self.db.execute('INSERT INTO {0.table} DEFAULT VALUES'.format(self)).lastrowid
	
	def copy(self, id):
		return self.db.execute('INSERT INTO {0.table} ({cols}) SELECT {cols} FROM {0.table} WHERE id=:id'.format(self,
				cols = ','.join(self.schema.keys()),
			), {'id':id}).lastrowid
	
	def save(self, id, data):
		data = dataToRow(data)
		keys = set(self.schema.keys()) & set(data.keys())
		data['id'] = id
		self.db.execute('UPDATE {0.table} SET {cols} WHERE id=:id'.format(self,
			cols = ','.join([c+'=:'+c for c in keys])
		), data)

	
	def swap(self, id, sw):
		if id == sw: return
		idOrd = self.db.execute('SELECT ord FROM {0.table} WHERE id=:id'.format(self), {'id':id}).fetchone()['ord']
		swOrd = self.db.execute('SELECT ord FROM {0.table} WHERE id=:sw'.format(self), {'sw':sw}).fetchone()['ord']
		self.db.execute('UPDATE {0.table} SET ord=:swOrd WHERE id=:id'.format(self), {'swOrd':swOrd, 'id':id})
		self.db.execute('UPDATE {0.table} SET ord=:idOrd WHERE id=:sw'.format(self), {'idOrd':idOrd, 'sw':sw})
	
	def remove(self, id):
		self.db.execute('DELETE FROM {0.table} WHERE id=:id'.format(self), {'id':id})



class Sqlite:
	
	def __init__(self, path, schemaVersion, definition):
		self.schema = collections.OrderedDict([(t[0],t[1]) for t in definition])
		
		def dbFile(version): return '{}.{}.sqlite'.format(path, version)
		
		self.db = sqlite3.connect(dbFile(schemaVersion))
		with self.db:
			self.db.row_factory = rowToData
			self.db.execute('PRAGMA synchronous  = OFF;')
			
			if not self.db.execute('SELECT * FROM sqlite_master;').fetchone():	# db empty
				logging.info(__name__+": creating tables")
				self.create(definition)
				self.db.execute('PRAGMA user_version = {};'.format(schemaVersion))
				
				for oldVersion in reversed(range(1, schemaVersion)):
					oldDbFile = dbFile(oldVersion)
					if os.path.isfile(oldDbFile):
						logging.info(__name__+": migrating from old database {}".format(oldDbFile))
						try:
							oldDb = sqlite3.connect('file:{}?mode=ro'.format(oldDbFile), uri=True)
							oldDb.row_factory = rowToData
							self.migrate(oldDb, oldVersion)
						except:
							logging.exception(__name__+": failed to migrate from old database")
						break
			
			self.db.execute('PRAGMA foreign_keys = ON;')	#check foreign keys after migrating
	
	
	def create(self, definition):
		for table in definition:
			self.db.execute('CREATE TABLE IF NOT EXISTS {table} (id INTEGER PRIMARY KEY AUTOINCREMENT,ord INTEGER,{columns}{constraint})'.format(
				table = table[0],
				columns = ','.join([c+' '+d for c,d in table[1].items()]),
				constraint = ',{}'.format(table[2]) if len(table)>=3 else ''
			))
			self.db.execute('CREATE TRIGGER {table}_ord AFTER INSERT ON {table} FOR EACH ROW WHEN NEW.ord IS NULL BEGIN UPDATE {table} SET ord = NEW.rowid WHERE rowid = NEW.rowid; END;'.format(
				table = table[0]
			))
	
	
	def migrate(self, oldDb, oldVersion):
		oldTables = [t['name'] for t in   oldDb.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
		newTables = [t['name'] for t in self.db.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()]
		tables    = [t for t in newTables if t in oldTables]
		
		for table in tables:
			oldColumns = [d[0] for d in   oldDb.execute("SELECT * FROM {}".format(table)).description]
			newColumns = [d[0] for d in self.db.execute("SELECT * FROM {}".format(table)).description]
			columns    = [c for c in newColumns if c in oldColumns]
			for oldRow in oldDb.execute("SELECT * FROM {}".format(table)).fetchall():
				self.db.execute("INSERT INTO {} ({}) VALUES ({})".format(table, ','.join(columns), ','.join([':'+c for c in columns])), dataToRow(oldRow))
	
	
	def table(self, table):
		return Table(self, table)
