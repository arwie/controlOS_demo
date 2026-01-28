import web
from shared.claude import ClaudeChat, ClaudeModel


MAX_TOKENS      = 10000
THINKING_TOKENS = 6000


web.document.imports.append('hmi/programs/cnc_paint')



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