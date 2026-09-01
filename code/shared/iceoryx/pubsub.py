# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import get_origin, Any
from ctypes import memmove, Structure, c_uint8
import msgpack
from . import iox2, IoxService, IoxPort, IoxSample
from .event import IoxEvent, IoxNotifier, IoxListener
from shared.condition import poll
from shared.utils import instantiate



class IoxPublishSubscribe[T:Structure](IoxService):

	def __init__(self,
		name: str,
		msg_type:type[T] = iox2.Slice[c_uint8],
		*,
		publishers = 1,
		subscribers = 1,
		history = False,
	):
		super().__init__(name, lambda builder: builder \
			.publish_subscribe(msg_type) \
			.max_publishers(publishers) \
			.max_subscribers(subscribers) \
			.history_size(1 if history else 0) \
			.enable_safe_overflow(True) \
			.subscriber_max_buffer_size(1)
		)
		self.msg_type = msg_type
		self.history = history



class IoxPublisher[T:Structure](IoxPort[IoxPublishSubscribe[T]]):

	def __init__(self, service:IoxPublishSubscribe[T], *, initial_slice_len=512):
		builder = service.publisher_builder()
		if get_origin(service.msg_type) is iox2.Slice:
			builder = builder \
				.initial_max_slice_len(initial_slice_len) \
				.allocation_strategy(iox2.AllocationStrategy.PowerOfTwo)
		super().__init__(service, builder)
		if self.service.history:
			_pubsub_event.history_publishers.add(self)

	def __exit__(self, et, exc, tb):
		_pubsub_event.history_publishers.discard(self)
		super().__exit__(et, exc, tb)

	def send_copy(self, msg:T):
		self._inner.send_copy(msg)

	def send_msgpack(self, msg:Any):
		data = msgpack.packb(msg)
		assert data is not None
		sample = self.loan_slice_uninit(len(data))
		memmove(sample.payload().as_ptr(), data, len(data))
		sample.assume_init().send()


class IoxNotifyingPublisher[T:Structure](IoxPublisher[T]):

	def __init__(self, service:IoxPublishSubscribe[T], event_service:IoxEvent, **kwargs):
		super().__init__(service, **kwargs)
		self.notifyer = IoxNotifier(event_service)
		if self.service.history:
			_pubsub_event.history_notifiers.add(self.notifyer)

	def __enter__(self):
		self.notifyer.__enter__()
		return super().__enter__()

	def __exit__(self, et, exc, tb):
		_pubsub_event.history_notifiers.discard(self.notifyer)
		self.notifyer.__exit__(et, exc, tb)
		super().__exit__(et, exc, tb)

	def send_copy(self, msg:T):
		super().send_copy(msg)
		self.notifyer.notify()

	def send_msgpack(self, msg):
		super().send_msgpack(msg)
		self.notifyer.notify()



class IoxSubscriber[T:Structure](IoxPort[IoxPublishSubscribe[T]]):

	def __init__(self, service:IoxPublishSubscribe[T]):
		super().__init__(service, service.subscriber_builder())
		_pubsub_event.notify_subscriber_connected()

	def receive(self) -> IoxSample[T]|None:
		if sample := self._inner.receive():
			return IoxSample(sample)

	def receive_copy(self) -> T|None:
		if sample := self._inner.receive():
			return self.service.msg_type.from_buffer_copy(sample.payload().contents)

	def receive_msgpack(self) -> Any|None:
		if sample := self._inner.receive():
			p = sample.payload()
			return msgpack.unpackb((c_uint8 * p.len()).from_address(p.as_ptr()))

	def drain(self):
		while sample := self._inner.receive():
			sample.delete()


class IoxListeningSubscriber[T:Structure](IoxSubscriber[T]):

	def __init__(self, service:IoxPublishSubscribe[T], event_service:IoxEvent):
		super().__init__(service)
		self.listener = IoxListener(event_service)

	def __enter__(self):
		self.listener.__enter__()
		return super().__enter__()

	def __exit__(self, et, exc, tb):
		self.listener.__exit__(et, exc, tb)
		super().__exit__(et, exc, tb)

	async def poll_receive(self):
		return await poll(self.receive, self.listener)

	async def poll_receive_copy(self) -> T:
		return await poll(self.receive_copy, self.listener)

	async def poll_receive_msgpack(self) -> Any:
		return await poll(self.receive_msgpack, self.listener)



@instantiate
class _pubsub_event(IoxListener):

	SUBSCRIBER_CONNECTED		= iox2.EventId.new(1)

	history_publishers = set[IoxPublisher]()
	history_notifiers  = set[IoxNotifier]()

	def __init__(self):
		super().__init__(IoxEvent('iceoryx/pubsub_event'))
		self.notifier = IoxNotifier(self.service)

	def notify_subscriber_connected(self):
		self.notifier.notify_with_custom_event_id(self.SUBSCRIBER_CONNECTED)

	def handle(self, event_id):
		match event_id:
			case self.SUBSCRIBER_CONNECTED:
				for publisher in self.history_publishers:
					publisher.update_connections()
				for notifier in self.history_notifiers:
					notifier.notify()
