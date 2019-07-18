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


#ifndef CHANNELWEBSOCKET_HPP_
#define CHANNELWEBSOCKET_HPP_

#include <websocketpp/config/asio_no_tls.hpp>
#include <websocketpp/server.hpp>


class ChannelWebsocket : public QueuingChannel
{
public:

	ChannelWebsocket(const Message& args)
		: Channel("websocket", args), QueuingChannel(args)
	{
		port				= args["port"];
		auto receive		= args.value("receive", true);

		log["port"] = port;
		log["receive"] = receive;

		wsServer.init_asio();
		wsServer.set_reuse_addr(true);

		wsServer.set_open_handler([this](websocketpp::connection_hdl hdl)
		{
			{ lock_guard<mutex> lock(connectionsMtx);
				connections.insert(hdl);
			}
			pushMessage(make_unique<Message>(Message::Event::connect));
		});

		wsServer.set_close_handler([this](websocketpp::connection_hdl hdl)
		{
			{ lock_guard<mutex> lock(connectionsMtx);
				connections.erase(hdl);
			}
			if (connections.empty())
				pushMessage(make_unique<Message>(Message::Event::disconnect));
		});

		if (receive) {
			wsServer.set_message_handler([this](websocketpp::connection_hdl hdl, WsServer::message_ptr msg)
			{
				pushMessage(make_unique<Message>(msg->get_payload()));
			});
		}
		
		wsServer.get_elog().handler = [this](websocketpp::log::level l, const string& msg) {
			switch (l) {
				case websocketpp::log::elevel::fatal:
				case websocketpp::log::elevel::rerror:
					logMsg(LogError(msg));		break;
				case websocketpp::log::elevel::warn:
					logMsg(LogWarning(msg));	break;
				case websocketpp::log::elevel::info:
					logMsg(LogNotice(msg));		break;
				default:
					logMsg(LogDebug(msg));		break;
			}
		};
	}

	void open() override
	{
		wsServer.listen(websocketpp::lib::asio::ip::tcp::v4(), port);
		wsServer.start_accept();
		runner = thread([this](){
			logMsg(LogDebug("websocket runner started"));
			wsServer.run();
		});
		QueuingChannel::open();
	}


	void send(const Message& message) override
	{
		auto msgString = message.dump();

		lock_guard<mutex> lock(connectionsMtx);
		for(auto& con : connections) {
			try {
				wsServer.send(con, msgString, websocketpp::frame::opcode::text);
			} catch (websocketpp::exception& e) {
				logMsg(LogWarning(e.what()).func(__func__));
			}
		}
	}


	void close() override
	{
		wsServer.stop();
		runner.join();
		QueuingChannel::close();
	}


private:
	template <typename concurrency, typename names>
	class WebsocketLogger : public websocketpp::log::basic<concurrency, names> {
	public:
		_WEBSOCKETPP_CONSTEXPR_TOKEN_ WebsocketLogger(websocketpp::log::level l, websocketpp::log::channel_type_hint::value h)
			: websocketpp::log::basic<concurrency, names>(l, h) {}

		void write(websocketpp::log::level l, const char* msg) { write(l, string(msg)); }
		void write(websocketpp::log::level l, const string& msg) {
			if (this->dynamic_test(l) && handler) {
				handler(l, msg);
			}
		}
		
		function<void(websocketpp::log::level, const string&)> handler;
	};

	struct WebsocketConfig : public websocketpp::config::core {
		typedef WebsocketConfig				type;
		typedef websocketpp::config::core	base;

		typedef base::concurrency_type concurrency_type;

		typedef base::request_type request_type;
		typedef base::response_type response_type;

		typedef base::message_type message_type;
		typedef base::con_msg_manager_type con_msg_manager_type;
		typedef base::endpoint_msg_manager_type endpoint_msg_manager_type;

		typedef WebsocketLogger<concurrency_type, websocketpp::log::alevel> alog_type;
		typedef WebsocketLogger<concurrency_type, websocketpp::log::elevel> elog_type;

		typedef base::rng_type rng_type;

		struct transport_config : public base::transport_config {
			typedef type::concurrency_type concurrency_type;
			typedef type::alog_type alog_type;
			typedef type::elog_type elog_type;
			typedef type::request_type request_type;
			typedef type::response_type response_type;
			typedef websocketpp::transport::asio::basic_socket::endpoint
				socket_type;
		};

		typedef websocketpp::transport::asio::endpoint<transport_config>
			transport_type;

		static const websocketpp::log::level alog_level = websocketpp::log::alevel::none;
	};

	using WsServer = websocketpp::server<WebsocketConfig>;

	int port;
	WsServer wsServer;
	thread runner;
	set<websocketpp::connection_hdl, std::owner_less<websocketpp::connection_hdl>> connections;
	mutex connectionsMtx;
};

#endif /* CHANNELWEBSOCKET_HPP_ */
