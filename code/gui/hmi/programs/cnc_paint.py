from asyncio import sleep
import web
from shared.claude import ClaudeChat, ClaudeModel
from shared.iceoryx.pubsub import IoxNotifyingPublisher, IoxSubscriber, poll
from shared.topics.codesys import codesys_fbk_pubsub
from shared.topics.programs import cnc_paint_pubsub, cnc_paint_event
from shared.coordinates import Pos, asdict


MAX_TOKENS      = 10000
THINKING_TOKENS = 6000


web.document.imports.append('hmi/programs/cnc_paint')
web.site.show(__name__, lambda: cnc_paint_pubsub.dynamic_config.number_of_subscribers)



draw_polylines = {
	"name": "draw_polylines",
	"description": "Draw a series of polylines on the canvas.",
	"strict": True,
	"input_schema": {
		"type": "object",
		"properties": {
			"polylines": {
				"type": "array",
				"description": "Array of polylines to draw",
				"items": {
					"type": "array",
					"description": "A single polyline: array of point objects",
					"items": {
						"type": "object",
						"properties": {
							"x": {"type": "number", "description": "X coordinate in mm"},
							"y": {"type": "number", "description": "Y coordinate in mm"}
						},
						"required": ["x", "y"],
						"additionalProperties": False
					}
				}
			}
		},
		"required": ["polylines"],
		"additionalProperties": False
	}
}

system_prompt = """
	You are a drawing assistant for a delta robot plotter.
	When the user asks you to draw something, respond conversationally first AND call the draw_polylines tool with actual coordinates.
	Think about the shape, calculate approximate coordinates, and ALWAYS provide actual points.
	IMPORTANT RULES:
	- Each polyline is an array of {x, y} points
	- Use multiple polylines for separate strokes (pen lifts between them)
	- Canvas: circular area, 160mm radius, origin at center (0,0), positive Y points up
	- Scale to fill the canvas by default
"""



@web.handler
class claude(web.RequestHandler):

	async def post(self):
		request = self.read_json()

		chat = ClaudeChat(
			ClaudeModel[request['model']],
			MAX_TOKENS,
			system = system_prompt,
			thinking_tokens = THINKING_TOKENS if request['thinking'] else 0,
			tools = [draw_polylines],
		)

		response = await chat(request['prompt'])

		result = {}
		for block in response:
			match block["type"]:
				case "thinking":
					result['thinking'] = block["thinking"]
				case "text":
					result['answer'] = block["text"]
				case "tool_use":
					if block["name"] == draw_polylines['name']:
						result['polylines'] = block["input"]["polylines"]

		self.write(result)



@web.handler
class draw(web.RequestHandler):

	cmd_publisher = IoxNotifyingPublisher(cnc_paint_pubsub, cnc_paint_event)

	def post(self):
		self.cmd_publisher.send_msgpack({
			'cmd': 1,
			'paths': self.read_json(),
		})



@web.handler
class info(web.WebSocketHandler):

	async def update(self):
		update_period=1/20
		with IoxSubscriber(codesys_fbk_pubsub) as fbk_subscriber:
			while True:
				with await poll(fbk_subscriber.receive) as sample:
					fbk = sample.payload().contents
					msg = {
						'robot': {
							'pos': asdict(Pos(*fbk.rbt_pos)),
						},
					}
				await self.write_message(msg)
				await sleep(update_period)
