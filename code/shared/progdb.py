from shared.sqlite import Sqlite, SqliteTable


class Progdb(Sqlite):
	def __init__(self):
		super().__init__('/etc/app/progdb', 1, [
			('progs', {
				'name':					"TEXT		DEFAULT 'new program'",
				'description':			"TEXT		DEFAULT ''",
				'speed':				"INTEGER	DEFAULT 50",
			}),
			('points', {
				'prog_id':				"INTEGER	NOT NULL	REFERENCES progs	ON DELETE CASCADE",
				'path_x':				"DOUBLE		DEFAULT 0",
				'path_y':				"DOUBLE		DEFAULT 0",
				'path_z':				"DOUBLE		DEFAULT 0",
				'path_r':				"DOUBLE		DEFAULT 0",
			}),
		])


progdb = Progdb()
progs	= SqliteTable(progdb, 'progs')
points	= SqliteTable(progdb, 'points')
