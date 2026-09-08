@tool
extends Node3D


const params = {
	'axis_angle': 45.0,
	'outer_radius': 0.39215,
	'inner_radius': 0.042,
	'rods_length': 0.400,
	'rods_distance': 0.080,
}
const thetas = [0, 120, 240]


@export_tool_button("Setup transforms") var setup_transforms_action:
	get: return setup_transforms

func setup_transforms():
	for i in thetas.size():
		var turn := Basis(Vector3(0, 1, 0), deg_to_rad(thetas[i]))
		rails[i].transform = Transform3D(
			turn * Basis(Vector3(1, 0, 0), deg_to_rad(180.0 - params['axis_angle'])),
			turn * Vector3(0, 0, params['outer_radius'])
		)
		var reach := params['rods_distance'] / 2
		rods_l[i].transform = Transform3D(Basis.IDENTITY, Vector3(-reach, 0, 0))
		rods_r[i].transform = Transform3D(Basis.IDENTITY, Vector3( reach, 0, 0))
	cache_geometry()


# The rig itself never changes shape, only its joints move.
@onready var plate: Node3D = $plate
@onready var rails: Array[Node3D] = [$rail_0, $rail_120, $rail_240]
@onready var arms: Array[Node3D] = [$rail_0/arm, $rail_120/arm, $rail_240/arm]
@onready var rods_l: Array[Node3D] = [$rail_0/arm/rod_l, $rail_120/arm/rod_l, $rail_240/arm/rod_l]
@onready var rods_r: Array[Node3D] = [$rail_0/arm/rod_r, $rail_120/arm/rod_r, $rail_240/arm/rod_r]

# Geometry that only moves when the rails do, worked out once by
# cache_geometry() so the per-frame update is plain arithmetic.
var arm_bases: Array[Basis] = []           # robot space -> arm space
var axis_origins := PackedVector3Array()   # carriage position at axis zero
var axis_dirs := PackedVector3Array()      # rail travel direction, unit length
var plate_joints := PackedVector3Array()   # plate joint centre, plate relative
var axes := Vector3.INF                    # axis positions the pose was built for

var socket := WebSocketPeer.new()



func _ready() -> void:
	cache_geometry()
	update_kinematics()
	if socket.connect_to_url("ws://90.0.0.1:8000/studio.sim.robot") != OK:
		push_warning('Failed to connect WebSocket')


func _process(_delta: float) -> void:
	socket.poll()
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		if socket.get_available_packet_count():
			var msg = JSON.parse_string(socket.get_packet().get_string_from_utf8())
			for index in arms.size():
				arms[index].position.z = msg[index] / 1000
	update_kinematics()


## Reduces the rails to the values update_kinematics() runs on. Call this after
## anything but the arms themselves moves.
func cache_geometry() -> void:
	arm_bases.clear()
	axis_origins.clear()
	axis_dirs.clear()
	plate_joints.clear()
	axes = Vector3.INF
	for i in thetas.size():
		var rail := rails[i]
		var arm := arms[i]
		arm_bases.append((rail.basis * arm.basis).inverse())
		# Rail-local transforms only reach as far as the rail; the carriage slides
		# along the rail's own Z, so in robot space it is a ray.
		axis_dirs.append(rail.basis.z)
		axis_origins.append(rail.transform * Vector3(arm.position.x, arm.position.y, 0))
		plate_joints.append(
			Basis(Vector3(0, 1, 0), deg_to_rad(thetas[i])) * Vector3(0, 0, params['inner_radius'])
		)


## Forward kinematics of the linear delta: places the plate for the current axis
## positions (the arm offsets along their rails) and swings the rods to match.
func update_kinematics() -> void:
	var q := Vector3(arms[0].position.z, arms[1].position.z, arms[2].position.z)
	if q == axes:
		return
	axes = q

	# Both rods of a rail are a parallelogram: their lateral offsets on the
	# carriage and on the plate cancel, so the pair acts as a single rod of
	# rods_length between the carriage and the plate's joint centre. That leaves
	# the plate origin on a sphere around the carriage, shifted back by the
	# plate's radial offset.
	var a := axis_origins[0] + axis_dirs[0] * q.x - plate_joints[0]
	var b := axis_origins[1] + axis_dirs[1] * q.y - plate_joints[1]
	var c := axis_origins[2] + axis_dirs[2] * q.z - plate_joints[2]

	var position = trilaterate(a, b, c, params['rods_length'])
	if position == null:
		return  # axis combination outside the workspace
	plate.position = position

	# Each sphere centre is already the plate joint pulled back onto the
	# carriage, so the vector to it is the rod, at its full length by definition.
	aim_rods(0, position - a)
	aim_rods(1, position - b)
	aim_rods(2, position - c)


## Intersects three spheres of equal radius, returning the lower of the two
## solutions, or null if they do not meet.
func trilaterate(a: Vector3, b: Vector3, c: Vector3, radius: float):
	var n1 := b - a
	var n2 := c - a
	var line := n1.cross(n2)
	var line_sq := line.length_squared()
	if line_sq < 1e-12:
		return null  # degenerate arrangement, the centres are collinear

	# Measured from `a`, equal radii reduce the other two spheres to the planes
	# n·x = |n|² / 2, and Cramer's rule against `line` (which is normal to both)
	# gives the one point of their intersection line closest to `a`.
	var point := (n2.cross(line) * n1.length_squared() + line.cross(n1) * n2.length_squared()) \
		/ (2.0 * line_sq)

	# That point is perpendicular to `line`, so the two solutions sit
	# symmetrically along it at the half chord of the sphere around `a`.
	var half_chord := radius * radius - point.length_squared()
	if half_chord < 0.0:
		return null
	# Dividing under the root rescales the step for `line` being unnormalised.
	half_chord = sqrt(half_chord / line_sq)
	return a + point + line * (-half_chord if line.y > 0.0 else half_chord)


## Swings a rail's rod pair, which run from their origins along local -Z, onto
## the given robot space direction.
func aim_rods(i: int, direction: Vector3) -> void:
	var z: Vector3 = arm_bases[i] * direction / -params['rods_length']
	# The ball joints pivot around the arm's X axis, so keep the rod's own X as
	# close to it as the swing permits instead of letting the rod roll.
	var x := (Vector3(1, 0, 0) - z * z.x).normalized()
	var pose := Basis(x, z.cross(x), z)
	rods_l[i].basis = pose
	rods_r[i].basis = pose
