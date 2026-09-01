import web
from shared.conf import Conf
from shared.iceoryx.pubsub import IoxSubscriber, poll
from shared.topics.programs import calib_robot_pubsub


web.document.imports.append('hmi/programs/calib_robot')
web.site.show(__name__, lambda: calib_robot_pubsub.dynamic_config.number_of_publishers)



@web.handler
class drives(web.RequestHandler):

	conf = Conf('/etc/app/drives.conf')
	calib_subscriber = IoxSubscriber(calib_robot_pubsub)

	async def prepare(self):
		self.encoders:dict = await poll(self.calib_subscriber.receive_msgpack)

	async def get(self):
		self.write([{
			'name': name,
			'encoder': encoder,
			'offset': self.conf.getfloat(name, 'offset', fallback=0.0),
		} for name, encoder in self.encoders.items()])

	async def post(self):
		drive = self.read_json()
		offset = drive['calibPos'] - self.encoders[drive['name']]
		self.conf.update({ drive['name']: { 'offset': offset } })
		self.conf.save()
