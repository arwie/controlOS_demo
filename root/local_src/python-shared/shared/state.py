# Copyright (c) 2019 Artur Wiebe <artur@4wiebe.de>
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


import asyncio



class State:
	def __init__(self):
		self.state = frozenset()
		self.observers = set()
		asyncio.get_event_loop().create_task(self.run())
	
	
	async def run(self):
		journalctl = await asyncio.create_subprocess_exec('journalctl','--follow','--output=cat','--lines=0','_PID=1', stdout=asyncio.subprocess.PIPE)
		
		timeout = 0
		while True:
			try:
				line = await asyncio.wait_for(journalctl.stdout.readline(), timeout)
				if b'target' in line:
					timeout = 0.1
				continue
			except asyncio.TimeoutError:
				timeout = None
			
			systemctl  = await asyncio.create_subprocess_exec('systemctl','list-units','--no-pager','--no-legend','--plain','--type=target','--state=active', stdout=asyncio.subprocess.PIPE)
			targets,*_ = await systemctl.communicate()
			newState = frozenset(t.partition('.target')[0] for t in targets.decode().splitlines())
			
			if newState != self.state:
				self.state = newState
				for observer in self.observers:
					observer.set()


state = State()



def subscribe():
	observer = asyncio.Event()
	observer.set()
	state.observers.add(observer)
	return observer

def unsubscribe(observer):
	state.observers.remove(observer)

async def update(observer):
	await observer.wait()
	observer.clear()
	return state.state
