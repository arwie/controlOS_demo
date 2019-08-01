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


#ifndef CHANNELLOG_HPP_
#define CHANNELLOG_HPP_

#include <unistd.h>
#include <sys/syscall.h>


static ChannelPtr channelLog;

static void logMsg(Log&& msg)
{
	ChannelPtr channelLogCopy = channelLog;
	if (!channelLogCopy) return;

	msg.file("mccom");

	channelLogCopy->send(msg);
}


class ChannelLog : public QueuingChannel
{
public:
	ChannelLog(const Message& args)
		: Channel("log", args), QueuingChannel(args),
		  base(args.value("base", json::object())),
		  priority(args.value("priority", LogInfo::priority))
	{}

	void open() override
	{
		if (channelLog) throw runtime_error("log channel already open");
		channelLog = shared_from_this();

		QueuingChannel::open();
	}

	void send(const Message& message) override
	{
		thread_local pid_t  tid = syscall(SYS_gettid);	// cache tid (reduce syscalls)

		if (message.value("priority", LogDebug::priority) > priority)
			return;

		auto messagePtr = make_unique<Message>(message);


		messagePtr->merge(base);

		(*messagePtr)["tid"] = tid;

		pushMessage(move(messagePtr));
	}

	void close() override
	{
		channelLog.reset();

		QueuingChannel::close();
	}

private:
	Message base;
	int priority;
};

#endif /* CHANNELLOG_HPP_ */
