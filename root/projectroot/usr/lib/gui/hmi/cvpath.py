import server
import asyncio



class Handler(server.RequestHandler):
	
	def get(self):
		self.set_header('Content-Type', 'image/webp')
		with open('/tmp/cvpath.webp', 'rb') as f:
			self.write(f.read())
	
	async def post(self):
		cvpath   = await asyncio.create_subprocess_exec('/usr/sbin/cvpath', stdout=asyncio.subprocess.PIPE)
		paths,*_ = await cvpath.communicate()
		self.write(paths)



server.addAjax(__name__, Handler)
