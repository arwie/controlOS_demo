# SPDX-FileCopyrightText: 2026 Artur Wiebe <artur@4wiebe.de>
# SPDX-License-Identifier: MIT

## Equivalent of the three.js OrbitControls.
## Left button orbits, right or middle button pans, the wheel zooms.

class_name OrbitCamera
extends Camera3D


@export var distance := 2.0
@export var rotate_speed := 0.5
@export var zoom_speed := 0.1
@export var min_distance := 0.1
@export var max_distance := 10.0
@export var yaw := deg_to_rad(-25.0)
@export var pitch := deg_to_rad(20.0)
@export var target := Vector3(0, 1, 0)


func _ready() -> void:
	_place()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		var height := float(get_viewport().get_visible_rect().size.y)

		if motion.button_mask & MOUSE_BUTTON_MASK_LEFT:
			yaw -= TAU * rotate_speed * motion.relative.x / height
			pitch = clampf(pitch + TAU * rotate_speed * motion.relative.y / height,
				deg_to_rad(-89.0), deg_to_rad(89.0))
			_place()

		elif motion.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			# move the target so the scene follows the cursor
			var per_pixel := 2.0 * distance * tan(deg_to_rad(fov) / 2.0) / height
			target += (global_basis.y * motion.relative.y - global_basis.x * motion.relative.x) * per_pixel
			_place()

	elif event is InputEventMouseButton and event.is_pressed():
		match (event as InputEventMouseButton).button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_zoom(1.0 - zoom_speed)
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom(1.0 + zoom_speed)


func _zoom(factor: float) -> void:
	distance = clampf(distance * factor, min_distance, max_distance)
	_place()


func _place() -> void:
	position = target + distance * Vector3(
		sin(yaw) * cos(pitch),
		sin(pitch),
		cos(yaw) * cos(pitch))
	look_at(target, Vector3.UP)
