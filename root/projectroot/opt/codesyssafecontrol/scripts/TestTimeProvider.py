#!/usr/bin/python -Bu

from time import sleep, monotonic_ns
import socket
import struct


TARGET = ("127.0.0.1", 60000)
PERIOD = 0.003


sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

count = 0
while True:
	sleep(PERIOD)

	count += 1
	timestamp = int(monotonic_ns() // 1000)

	sock.sendto(
		struct.pack('<HHI', 0x5AFE, count & 0xFFFF, timestamp & 0xFFFFFFFF),
		TARGET
	)
