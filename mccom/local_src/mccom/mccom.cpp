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


#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <thread>
#include <map>
#include <set>
#include <queue>
#include <stack>
#include <mutex>
#include <condition_variable>
#include <memory>
#include <functional>
#include <exception>

using namespace std;

#define DEBUG(x)	if (true) { cout << x << endl; }


class Message; using MessagePtr = unique_ptr<Message>;
class Channel; using ChannelPtr = shared_ptr<Channel>;

class Log;
static void logMsg(Log&&);


#include "Message.hpp"
#include "Log.hpp"
#include "Channel.hpp"
#include "ChannelLog.hpp"
#include "ChannelNotify.hpp"
#include "ChannelState.hpp"
#include "ChannelFifo.hpp"
#include "ChannelWebsocket.hpp"
#include "ChannelUdp.hpp"
#include "ChannelFile.hpp"
#include "Manager.hpp"

#include "amcs.h"


static Manager manager;
thread_local MessagePtr messagePtr(new Message());
thread_local stack<MessagePtr> messageStack;


static int mccom_open(int channelType, int *error) noexcept
{
	*error = 0;
	try {
		switch(channelType) {
			case  1: return manager.openChannel(make_shared<ChannelLog>				(*messagePtr));
			case  2: return manager.openChannel(make_shared<ChannelNotify>			(*messagePtr));
			case  3: return manager.openChannel(make_shared<ChannelState>			(*messagePtr));
			case  4: return manager.openChannel(make_shared<ChannelFifo>			(*messagePtr));
			case  5: return manager.openChannel(make_shared<ChannelWebsocket>		(*messagePtr));
			case  7: return manager.openChannel(make_shared<ChannelFile>			(*messagePtr));
			case  8: return manager.openChannel(make_shared<ChannelUdpSender>		(*messagePtr));
			case  9: return manager.openChannel(make_shared<ChannelUdpReceiver>		(*messagePtr));
			default: throw runtime_error("unknown channel type");
		}
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__));
		DEBUG("mccom_open: " << e.what());
	}
	return -1;
}

static int mccom_receive(int channelId, chrono::milliseconds timeout, int *error) noexcept
{
	*error = 0;
	try {
		return manager.getChannel(channelId)->receive(messagePtr, timeout);
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__));
	}
	return false;
}

static void mccom_send(int channelId, int *error) noexcept
{
	*error = 0;
	try {
		manager.getChannel(channelId)->send(*messagePtr);
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__));
	}
}

static void mccom_send_self(int channelId, int *error) noexcept
{
	*error = 0;
	try {
		manager.getChannel(channelId)->sendSelf(*messagePtr);
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__));
	}
}

static void mccom_reset(int channelId) noexcept
{
	try {
		manager.getChannel(channelId)->reset();
	} catch (exception& e) {
		logMsg(LogError(e.what()).func(__func__));
	}
}

static void mccom_close(int channelId) noexcept
{
	try {
		manager.closeChannel(channelId);
	} catch (exception& e) {
		logMsg(LogError(e.what()).func(__func__));
	}
}

static void mccom_close_all() noexcept
{
	try {
		manager.closeAllChannels();
	} catch (exception& e) {
		logMsg(LogError(e.what()).func(__func__));
	}
}


static void mccom_clear(int *error) noexcept
{
	*error = 0;
	try {
		messagePtr.reset(new Message());
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__));
	}
}


static void mccom_store(int *error) noexcept
{
	*error = 0;
	try {
		if (messageStack.size() >= 5)
			throw runtime_error("message stack full");

	 	messageStack.emplace(move(messagePtr));
		messagePtr.reset(new Message());
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__));
	}
}

static void mccom_restore(int *error) noexcept
{
	*error = 0;
	try {
		messagePtr = move(messageStack.top());
		messageStack.pop();
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__));
	}
}


static void mccom_with(SYS_STRING* path) noexcept
{
	try {
		messagePtr->with(amcsGetString(path));
	}
	catch (exception& e) {
		logMsg(LogError(e.what()).func(__func__));
	}
}



static int mccom_size(SYS_STRING* path) noexcept
{
	try {
	 	return (*messagePtr)[messagePtr->withPath(amcsGetString(path))].size();
	} catch (exception& e) {
		logMsg(LogError(e.what()).func(__func__));
	}
	return 0;
}


template<class Type>
static Type mccom_get(SYS_STRING* path, int *error) noexcept
{
	*error = 0;
	try {
	 	return (*messagePtr)[messagePtr->withPath(amcsGetString(path))];
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__).log("path", amcsGetString(path)));
	}
	return Type();
}

static string mccom_get_json(SYS_STRING* path, int *error) noexcept
{
	*error = 0;
	try {
		return (*messagePtr)[messagePtr->withPath(amcsGetString(path))].dump();
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__).log("path", amcsGetString(path)));
	}
	return string();
}


template<class Type>
static void mccom_put(SYS_STRING* path, Type value, int *error) noexcept
{
	*error = 0;
	try {
		(*messagePtr)[messagePtr->withPath(amcsGetString(path))] = value;
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__).log("path", amcsGetString(path)));
	}
}

static void mccom_put_string(SYS_STRING* path, SYS_STRING* value, int *error) noexcept
{
	try {
		(*messagePtr)[messagePtr->withPath(amcsGetString(path))] = amcsGetString(value);
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__).log("path", amcsGetString(path)));
	}
}

static void mccom_put_json(SYS_STRING* path, SYS_STRING* value, int *error) noexcept
{
	*error = 0;
	try {
		auto valueStr = amcsGetString(value);
		replace(valueStr.begin(), valueStr.end(), '`', '"');	//allow coding json strings in basic
		(*messagePtr)[messagePtr->withPath(amcsGetString(path))] = json::parse(valueStr);
	} catch (exception& e) {
		*error = 1;
		logMsg(LogError(e.what()).func(__func__).log("path", amcsGetString(path)));
	}
}



 
 
extern "C" {

	int MCCOM_OPEN(int channelType, int *error) {
		return mccom_open(channelType, error);
	}

	int MCCOM_RECEIVE(int channelId, int timeout, int *error) {
		return mccom_receive(channelId, chrono::milliseconds(timeout), error);
	}

	void MCCOM_SEND(int channelId, int *error) {
		mccom_send(channelId, error);
	}

	void MCCOM_SEND_SELF(int channelId, int *error) {
		mccom_send_self(channelId, error);
	}

	void MCCOM_RESET(int channelId) {
		mccom_reset(channelId);
	}

	void MCCOM_CLOSE(int channelId) {
		mccom_close(channelId);
	}

	void MCCOM_CLEAR(int *error) {
		mccom_clear(error);
	}

	void MCCOM_STORE(int *error) {
		mccom_store(error);
	}

	void MCCOM_RESTORE(int *error) {
		mccom_restore(error);
	}

	void MCCOM_WITH(SYS_STRING** path) {
		mccom_with(*path);
	}

	int MCCOM_SIZE(SYS_STRING** path) {
		return mccom_size(*path);
	}

	int MCCOM_GET_BOOL(SYS_STRING** path, int *error) {
		return mccom_get<bool>(*path, error);
	}

	int MCCOM_GET_LONG(SYS_STRING** path, int *error) {
		return mccom_get<int>(*path, error);
	}

	double MCCOM_GET_DOUBLE(SYS_STRING** path, int *error) {
		return mccom_get<double>(*path, error);
	}

	SYS_STRING* MCCOM_GET_STRING(SYS_STRING** path, int *error)
	{
		auto str = mccom_get<string>(*path, error);
		return str_GetString((unsigned char*)str.c_str(), str.length(), ASCII8_STRING_TYPE);
	}

	SYS_STRING* MCCOM_GET_JSON(SYS_STRING** path, int *error) {
		auto str = mccom_get_json(*path, error);
		return str_GetString((unsigned char*)str.c_str(), str.length(), ASCII8_STRING_TYPE);
	}

	void MCCOM_PUT_BOOL(SYS_STRING** path, int value, int *error) {
		mccom_put<bool>(*path, value, error);
	}

	void MCCOM_PUT_LONG(SYS_STRING** path, int value, int *error) {
		mccom_put(*path, value, error);
	}

	void MCCOM_PUT_DOUBLE(SYS_STRING** path, double value, int *error) {
		mccom_put(*path, value, error);
	}

	void MCCOM_PUT_STRING(SYS_STRING** path, SYS_STRING** value, int *error) {
		mccom_put_string(*path, *value, error);
	}

	void MCCOM_PUT_JSON(SYS_STRING** path, SYS_STRING** value, int *error) {
		mccom_put_json(*path, *value, error);
	}


	__attribute__ ((__destructor__))
	void MCCOM_CLOSE_ALL(void) {
		mccom_close_all();
	}
}
