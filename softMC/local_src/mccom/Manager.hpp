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


#ifndef MANAGER_HPP_
#define MANAGER_HPP_


class Manager
{
public:

	int openChannel(ChannelPtr&& channel)
	{
		channel->open();

		lock_guard<mutex> lock(channelsMtx);
		auto channelId = nextChannelId++;
		channels.emplace(channelId, move(channel));

		return channelId;
	}


	ChannelPtr getChannel(int port)
	{
		lock_guard<mutex> lock(channelsMtx);
		return channels.at(port);
	}


	void closeChannel(int channelId)
	{
		unique_lock<mutex> lock(channelsMtx);
		ChannelPtr channel = move(channels.at(channelId));
		channels.erase(channelId);
		lock.unlock();

		channel->close();
	}

	void closeAllChannels()
	{
		lock_guard<mutex> lock(channelsMtx);

		for(auto& kv : channels)
			kv.second->close();

		channels.clear();
	}

private:

	map<int, ChannelPtr> channels;
	mutex channelsMtx;
	unsigned int nextChannelId = 1;
};

#endif /* MANAGER_HPP_ */
