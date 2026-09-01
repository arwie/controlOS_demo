# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

from __future__ import annotations
from typing import Any, Callable
from contextlib import AbstractContextManager
from ctypes import Structure, _Pointer
import sys
import iceoryx2
iox2: Any = iceoryx2



class IoxWrapper:

	def __init__(self, inner:Any):
		self._inner = inner

	def __getattr__(self, name):
		return getattr(self._inner, name)


class IoxDeletingWrapper(AbstractContextManager, IoxWrapper):

	def __enter__(self):
		return self

	def __exit__(self, et, exc, tb):
		self.delete()



class IoxService(IoxWrapper):

	node = iox2.NodeBuilder.new() \
		.name(iox2.NodeName.new(' '.join(sys.argv))) \
		.create(iox2.ServiceType.Ipc)

	def __init__(self, name:str, build:Callable[[Any], Any]):
		super().__init__(
			build(self.node.service_builder(iox2.ServiceName.new(name))).open_or_create()
		)


class IoxPort[T:IoxService](IoxDeletingWrapper):

	def __init__(self, service:T, builder):
		super().__init__(builder.create())
		self.service = service


class IoxSample[T:Structure](IoxDeletingWrapper):

	def payload(self) -> _Pointer[T]:
		return self._inner.payload()
