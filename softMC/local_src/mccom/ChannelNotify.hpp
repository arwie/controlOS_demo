// Copyright (c) 2016 Artur Wiebe <artur@4wiebe.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
// associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#ifndef CHANNELNOTIFY_HPP_
#define CHANNELNOTIFY_HPP_


class ChannelNotify : public Channel
{
public:
	ChannelNotify(const Message& args) : Channel("notify", args)	{}

	int receive(MessagePtr& message, chrono::milliseconds timeout) override
	{
		unique_lock<mutex> lock(blockMtx);

		if (timeout.count() > 0) {
			blockCond.wait_for(lock, timeout, [this]() { return state || closed; });
		}

		return (state ? Message::Event::notify : false);
	}


	void send(const Message& message) override
	{
		{ lock_guard<mutex> lock(blockMtx);
			state = true;
		}
		blockCond.notify_all();
	}


	void reset() override
	{
		{ lock_guard<mutex> lock(blockMtx);
			state = false;
		}
	}


private:
	bool state = false;
};

#endif /* CHANNELNOTIFY_HPP_ */
