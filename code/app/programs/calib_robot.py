from shared import app
from drives import robot_a, robot_b, robot_c, conf, drive_by_name



web_placeholder = app.web.placeholder('calib_robot')


class WebHandler(app.web.RequestHandler):

	async def get(self):
		self.write(
			[{
				'name': drive.name,
				'encoder': await drive.get_internal_pos(),
				'offset': conf.getfloat(drive.name, 'offset', fallback=0.0),
			} for drive in (robot_a, robot_b, robot_c)]
		)

	async def post(self):
		data = self.read_json()
		drive = drive_by_name[data['name']]
		offset = data['calibPos'] - await drive.get_internal_pos()
		conf.update({ drive.name: { 'offset': offset } })
		conf.save()



@app.context
async def exec():
	async with web_placeholder.handle(WebHandler):
		yield
