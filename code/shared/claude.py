from tornado.httpclient import AsyncHTTPClient, HTTPRequest, HTTPClientError
from tornado.httputil import HTTPHeaders
from pathlib import Path
from enum import StrEnum
import json
import sys
from shared import log
from shared.conf import Conf



API_URL = 'https://api.anthropic.com/v1/messages'


class ClaudeModel(StrEnum):
	HAIKU  = 'claude-haiku-4-5'
	SONNET = 'claude-sonnet-4-5'
	OPUS   = 'claude-opus-4-5'



conf = Conf('/etc/app/claude.conf')


_request_headers = HTTPHeaders({
	'Content-Type': 'application/json',
	'anthropic-version': '2023-06-01',
	'anthropic-beta': 'structured-outputs-2025-11-13',
	'x-api-key': conf.get('api','key')
})



class ClaudeChat:

	def __init__(
			self,
			model:str      = conf.get('api','model', fallback=ClaudeModel.HAIKU),
			max_tokens:int = conf.getint('api','max_tokens', fallback=1024),
			*,
			system:str = '',
			thinking_tokens:int = 0,
			tools:list[dict] = []
		):
		self.model = model
		self.max_tokens = max_tokens
		self.system = system
		self.thinking_tokens = thinking_tokens
		self.tools = tools
		self.history = list[dict]()


	async def __call__(self, message:str) -> list[dict]:

		self.history.append({
			'role': 'user',
			'content': message
		})

		request_body = json.dumps({
			'model': self.model,
			'max_tokens': self.max_tokens,
			'system': self.system,
			"thinking": {
				"type": "enabled",
				"budget_tokens": self.thinking_tokens
			} if self.thinking_tokens else {
				"type": "disabled",
			},
			'tools': self.tools,
			'messages': self.history
		})

		request = HTTPRequest(
			API_URL,
			method='POST',
			headers=_request_headers,
			body=request_body,
			request_timeout=120,
			validate_cert=False	#TODO
		)

		response = None
		try:
			response = await AsyncHTTPClient().fetch(request)
			response_data = json.loads(response.body)

			if response_data['stop_reason'] == 'max_tokens':
				raise Exception("Exceeded the requested max_tokens or the model's maximum")

			self.history.append({
				'role': 'assistant',
				'content': response_data['content']
			})
			return response_data['content']

		except HTTPClientError as e:
			response = e.response
			raise

		finally:
			(log.exception if sys.exception() else log.info)(
				f'Claude request: {message[:32]}...',
				REQUEST=request_body,
				RESPONSE=(response and response.body.decode())
			)




if __name__ == '__main__':
	import asyncio

	async def main():
		chat = ClaudeChat()
		question = "What is the capital of France? Answer in one sentence."
		answer = await chat(question)
		print(f'CHAT: {question} -> {answer[0]['text']}')

	asyncio.run(main())