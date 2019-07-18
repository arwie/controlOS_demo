// Copyright (c) 2018 Artur Wiebe <artur@4wiebe.de>
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


#ifndef CHANNELFILE_HPP_
#define CHANNELFILE_HPP_


class ChannelFile : public Channel
{
public:
	ChannelFile(const Message& args) : Channel("file", args), file(args["file"].get<string>()) {}

	int receive(MessagePtr& message, chrono::milliseconds timeout) override
	{
		string str;

		if(!getline(ifstream(file), str))
			return false;

		message.reset(new Message(str));
		return message->getEvent();
	}

	void send(const Message& message) override
	{
		ofstream(file) << message.dump() << endl;
	}

private:
	string file;
};

#endif /* CHANNELFILE_HPP_ */
