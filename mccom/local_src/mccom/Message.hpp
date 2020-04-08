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


#ifndef MESSAGE_HPP_
#define MESSAGE_HPP_

#include <json.hpp>
using json = nlohmann::json;


class Message : public json
{
public:
	enum Event {
		timeout			= 0,
		message			= 1,
		connect			= 10,
		disconnect		= 11,
		notify			= 20,
	};


	Message()									{}

	explicit Message(const json& rhs)
		:json(rhs)								{}

	explicit Message(const Event event)
		:event(event)							{}

	explicit Message(const string& str)
		:json(json::parse(str))					{}

	explicit Message(const char* buffer, const size_t length)
		:json(json::parse(buffer, buffer+length))	{}


	void with(const string& with)
	{
		prefix = with;
		if (prefix.front() != '/')
			prefix = "/" + prefix;
		if (prefix.back() != '/')
			prefix = prefix + "/";
	}

	json::json_pointer withPath(const string& path) const {
		if (path[0] == '/' || path.empty())
			return json::json_pointer(path);
		else
			return json::json_pointer(prefix + path);
	}


	void merge(const Message& other) {
		for (json::const_iterator it = other.begin(); it != other.end(); ++it)
			(*this)[it.key()] = it.value();
	}


	Event getEvent() const {
		return empty() ? event : Event::message;
	}


private:
	const Event event = Event::notify;
	string prefix = "/";
};

#endif /* MESSAGE_HPP_ */
