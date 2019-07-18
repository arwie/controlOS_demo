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


#ifndef CHANNELUDP_HPP_
#define CHANNELUDP_HPP_

#include <boost/asio.hpp>


class ChannelUdp : public QueuingChannel
{
public:

	ChannelUdp(const Message& args)
		: Channel("udp", args), QueuingChannel(args),
		  socket(asioService),
		  sendEndpoint(boost::asio::ip::address::from_string(args["send"]["address"]), args["send"]["port"])
	{
	}

	void open() override
	{
		QueuingChannel::open();
		socket.open(boost::asio::ip::udp::v4());
	}


	void send(const Message& message) override
	{
		socket.send_to(boost::asio::buffer(message.dump()), sendEndpoint);
	}


	void close() override
	{
		socket.close();
		QueuingChannel::close();
	}


private:
	boost::asio::io_service asioService;
	boost::asio::ip::udp::socket socket;
	boost::asio::ip::udp::endpoint sendEndpoint;
};

#endif /* CHANNELUDP_HPP_ */
