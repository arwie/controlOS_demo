extends Node3D

@onready var robot := %robot
var motion_socket := WebSocketPeer.new()


func _ready() -> void:
	motion_socket.connect_to_url("ws://90.0.0.1:8000/studio.sim.update")


func _process(delta: float) -> void:
	motion_socket.poll()
	while motion_socket.get_available_packet_count():
		var msg = JSON.parse_string(motion_socket.get_packet().get_string_from_utf8())

		var robot_axes = msg['robot']['axes']
		robot.set_axes(robot_axes[0] / 1000, robot_axes[1] / 1000, robot_axes[2] / 1000)
