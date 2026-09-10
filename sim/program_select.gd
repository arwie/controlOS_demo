extends Node


const programs_path = 'res://programs/%s.tscn'
const default_path  = 'res://main.tscn'

var program_socket := WebSocketPeer.new()


func _ready() -> void:
	program_socket.connect_to_url("ws://90.0.0.1/hmi.programs.select")


func _process(delta: float) -> void:
	program_socket.poll()
	if program_socket.get_available_packet_count():
		var program_name = JSON.parse_string(program_socket.get_packet().get_string_from_utf8())

		var path := programs_path % program_name
		if not ResourceLoader.exists(path):
			path = default_path

		get_tree().change_scene_to_file(path)
