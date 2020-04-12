import server
import asyncio



class Handler(server.RequestHandler):
	
	async def get(self):
		reader,writer = await asyncio.open_connection('o3d', 50010)
		length = await reader.readexactly(16)
		length = int(length[5:-2])
		content = await reader.readexactly(length)
		content = content[4:-2]
		writer.close()
		data = content.decode().split(';')[1:-1]
		result = {'count':int(data[1]), 'objects':[]}
		data = data[3:]
		result['objects'].append({
			'pos':{
				'x':float(data[4])*1000,
				'y':float(data[5])*1000,
				'z':float(data[6])*1000,
				'r':float(data[10]),
			}
		})
		self.writeJson(result)



server.addAjax(__name__, Handler)
