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


class ChannelUdpSender : public Channel
{
public:

	ChannelUdpSender(const Message& args)
		: Channel("udpSender", args),
		  socket(asioContext),
		  remoteEndpoint(boost::asio::ip::address::from_string(args["address"]), args["port"])
	{
	}

	void open() override
	{
		Channel::open();
		socket.open(boost::asio::ip::udp::v4());
	}

	void send(const Message& message) override
	{
		socket.send_to(boost::asio::buffer(message.dump()), remoteEndpoint);
	}

	void close() override
	{
		socket.close();
		Channel::close();
	}


private:
	boost::asio::io_context asioContext;
	boost::asio::ip::udp::socket socket;
	boost::asio::ip::udp::endpoint remoteEndpoint;
};



class ChannelUdpReceiver : public QueuingChannel
{
public:

	ChannelUdpReceiver(const Message& args)
		: Channel("udpReceiver", args), QueuingChannel(args),
		  socket(asioContext),
		  localEndpoint(boost::asio::ip::udp::v4(), args["port"]),
		  buffer(bufferData, sizeof(bufferData))
	{
	}

	void open() override
	{
		QueuingChannel::open();
		socket.open(boost::asio::ip::udp::v4());
		socket.bind(localEndpoint);
		runner = thread([this](){
			logMsg(LogDebug("udpReceiver runner started"));
			receive();
			asioContext.run();
		});
	}

	void receive()
	{
		socket.async_receive_from(buffer, remoteEndpoint, [this](boost::system::error_code ec, std::size_t bytes) {
			try {
				if (ec) throw runtime_error(ec.message());
				pushMessage(make_unique<Message>(bufferData, bytes));
			} catch (exception& e) {
				logMsg(LogError(e.what()).func("ChannelUdpReceiver::receive"));
			}
			receive();
		});
	}

	void close() override
	{
		asioContext.stop();
		runner.join();
		socket.close();
		QueuingChannel::close();
	}


private:
	boost::asio::io_context asioContext;
	boost::asio::ip::udp::socket socket;
	boost::asio::ip::udp::endpoint localEndpoint;
	boost::asio::ip::udp::endpoint remoteEndpoint;
	char bufferData[1500];
	boost::asio::mutable_buffer buffer;
	thread runner;
};

#endif /* CHANNELUDP_HPP_ */
