import server
from sqlite import TableHandler
from shared import progdb
import logging, json



class ProgdbTableHandler(TableHandler):
	def initialize(self, table):
		super().initialize(table, doPost={
			'touch':	self.doTouch,
		})
	
	def touch(self, id):
		self.db.execute('UPDATE {table} SET ord = (SELECT MAX(ord) FROM {table})+1 WHERE id=:id'.format(table=self.table.table), {'id':id})
	
	def doList(self):
		return self.table.list(order = 'name COLLATE NOCASE' if self.get_query_argument('sort', '') != 'false' else 'ord DESC')
	
	def doCreate(self):
		result = super().doCreate()
		self.touch(result['id'])
		return result
	
	def doCopy(self):
		result = super().doCopy()
		self.touch(result['id'])
		return result
	
	def doSave(self):
		super().doSave()
		self.touch(self.get_query_argument('id'))
	
	def doTouch(self):
		self.touch(self.get_query_argument('id'))


class ProgsHandler(ProgdbTableHandler):
	def initialize(self):
		super().initialize(progdb.progs)
	
	def doCopy(self):
		prog = super().doCopy()
		self.db.execute('UPDATE progs SET name=:prefix||name WHERE id=:id', {'prefix':"COPY:", 'id':prog['id']})
		
		pointsTable = progdb.progdb.table('points')
		points = pointsTable.list({'prog_id':self.get_query_argument('id')})
		for point in points:
			point['prog']['id'] = prog['id']
			pointsTable.create(point)
		
		return prog


class PointsHandler(TableHandler):
	def initialize(self):
		super().initialize(progdb.points)
	
	def doList(self):
		points = self.table.list({'prog_id':self.get_query_argument('prog_id')})
		for i,point in enumerate(points):
			point['swap'] = points[i-1]['id'] if i else 0
		return points
	
	def doCreate(self):
		point = self.readJson()
		point['prog_id'] = self.get_query_argument('prog_id')
		self.table.create(point)



server.addAjax(__name__+'/progs',	ProgsHandler)
server.addAjax(__name__+'/points',	PointsHandler)
