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


#ifndef LOG_HPP_
#define LOG_HPP_

class Log : public Message
{
public:

	template<class Type>
	Log&& log(const string& key, const Type& value)
	{
		(*this)[key] = value;
		return move(*this);
	}

	Log&& message(const string& message)	{ return log("message", message); }

	Log&& channel(const string& channel)	{ return log("channel", channel); }

	Log&& file(const string& file)			{ return log("code_file", file); }
	Log&& func(const string& func)			{ return log("code_func", func); }

	Log&& prg(const string& prg)			{ return log("prg", prg); }


protected:

	Log(const int prio)
	{
		(*this)["priority"] = prio;
	}

	Log(const int prio, const string& msg)
		: Log(prio)
	{
		message(msg);
	}
};



struct LogError		: public Log {
	LogError()						: Log(priority)			{}
	LogError(const string& msg)		: Log(priority, msg)	{}
	static const int priority = 3;
};

struct LogWarning	: public Log {
	LogWarning()					: Log(priority)			{}
	LogWarning(const string& msg)	: Log(priority, msg)	{}
	static const int priority = 4;
};

struct LogNotice	: public Log {
	LogNotice()						: Log(priority)			{}
	LogNotice(const string& msg)	: Log(priority, msg)	{}
	static const int priority = 5;
};

struct LogInfo		: public Log {
	LogInfo()						: Log(priority)			{}
	LogInfo(const string& msg)		: Log(priority, msg)	{}
	static const int priority = 6;
};

struct LogDebug		: public Log {
	LogDebug()						: Log(priority)			{}
	LogDebug(const string& msg)		: Log(priority, msg)	{}
	static const int priority = 7;
};


const int LogError::priority;
const int LogWarning::priority;
const int LogNotice::priority;
const int LogInfo::priority;
const int LogDebug::priority;

#endif /* LOG_HPP_ */
