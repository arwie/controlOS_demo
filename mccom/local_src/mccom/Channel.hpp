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


#ifndef CHANNEL_HPP_
#define CHANNEL_HPP_


class Channel : public enable_shared_from_this<Channel>
{
public:
	virtual void send(const Message& message)		{ throw logic_error("send() not implemented"); }
	virtual void sendSelf(const Message& message)	{ throw logic_error("sendSelf() not implemented"); }

	virtual int receive(MessagePtr& message, chrono::milliseconds timeout)	{ throw logic_error("receive() not implemented"); }

	virtual int count()		{ return 0; }

	virtual void open()		{ logMsg(LogDebug("channel opened")); }
	virtual void reset()	{}
	virtual ~Channel()		{}

	virtual void close()
	{
		{ lock_guard<mutex> lock(blockMtx);
			closed = true;
		}
		blockCond.notify_all();
		logMsg(LogDebug("channel closed"));
	}

	virtual void logMsg(Log&& msg)
	{
		msg.merge(log);
		::logMsg(move(msg));
	}

protected:
	Channel(const string& channelName, const Message& args)
		: log(args.value("log", json::object()))
	{
		log["channel"] = channelName;
	}

	bool closed = false;
	mutex blockMtx;
	condition_variable blockCond;
	Message log;
};



class QueuingChannel : public virtual Channel
{
public:

	int receive(MessagePtr& message, chrono::milliseconds timeout) override
	{
		unique_lock<mutex> lock(blockMtx);

		if (timeout.count() > 0) {
			blockCond.wait_for(lock, timeout, [this]() { return !receiveQueue.empty() || closed; });
		}

		if (receiveQueue.empty() || closed)
			return false;

		message = move(receiveQueue.front());
		receiveQueue.pop();

		return message->getEvent();
	}


	void sendSelf(const Message& message) override
	{
		pushMessage(make_unique<Message>(message));
	}


	int count() override
	{
		{ lock_guard<mutex> lock(blockMtx);
			return receiveQueue.size();
		}
	}

	void reset() override
	{
		queue<MessagePtr> emptyQueue;

		{ lock_guard<mutex> lock(blockMtx);
			swap(receiveQueue, emptyQueue);
		}
	}


protected:
	QueuingChannel(const Message& args) : Channel("", args)	{}

	void pushMessage(MessagePtr&& message)
	{
		{ lock_guard<mutex> lock(blockMtx);
			receiveQueue.emplace(move(message));
		}
		blockCond.notify_all();
	}


private:
	queue<MessagePtr> receiveQueue;
};


#endif /* CHANNEL_HPP_ */
