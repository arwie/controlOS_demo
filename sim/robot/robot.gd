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


# The rig itself never changes shape, only its joints move.
@onready var plate: Node3D = $plate
@onready var rails: Array[Node3D] = [$rail_a, $rail_b, $rail_c]
@onready var arms: Array[Node3D] = [$rail_a/arm, $rail_b/arm, $rail_c/arm]
@onready var rods_l: Array[Node3D] = [$rail_a/arm/rod_l, $rail_b/arm/rod_l, $rail_c/arm/rod_l]
@onready var rods_r: Array[Node3D] = [$rail_a/arm/rod_r, $rail_b/arm/rod_r, $rail_c/arm/rod_r]


@export_tool_button("Setup transforms") var setup_transforms_action:
	get: return setup_transforms

func setup_transforms():
	for i in thetas.size():
		var turn := Basis(Vector3(0, 1, 0), deg_to_rad(thetas[i]))
		rails[i].transform = Transform3D(
			turn * Basis(Vector3(1, 0, 0), deg_to_rad(180.0 - params['axis_angle'])),
			turn * Vector3(0, 0, params['outer_radius'])
		)
		rods_l[i].position.x = -params['rods_distance'] / 2
		rods_r[i].position.x = +params['rods_distance'] / 2
	cache_geometry()
	set_axes(0.3, 0.3, 0.3)


# Geometry that only moves when the rails do, worked out once by
# cache_geometry() so the per-frame update is plain arithmetic.
var rod_bases: Array[Basis] = []           # robot space -> arm space, over -rods_length
var axis_zeros := PackedVector3Array()     # rod sphere centre at axis zero
var axis_dirs := PackedVector3Array()      # rail travel direction, unit length
var axes := Vector3.INF                    # axis positions the pose was built for


func _ready() -> void:
	cache_geometry()
	update_kinematics()


func _process(_delta: float) -> void:
	update_kinematics()


## Slides the three carriages along their rails, in metres from axis zero. The
## pose follows on the next update_kinematics().
func set_axes(a: float, b: float, c: float) -> void:
	arms[0].position.z = a
	arms[1].position.z = b
	arms[2].position.z = c


## Reduces the rails to the values update_kinematics() runs on. Call this after
## anything but the arms themselves moves.
func cache_geometry() -> void:
	rod_bases.clear()
	axis_zeros.clear()
	axis_dirs.clear()
	axes = Vector3.INF
	for i in thetas.size():
		var rail := rails[i]
		var arm := arms[i]
		# aim_rods() only ever wants the direction over -rods_length, so scale the
		# basis by it here and the product comes out already normalised.
		rod_bases.append(
			(rail.basis * arm.basis).inverse().scaled(Vector3.ONE * (-1.0 / params['rods_length']))
		)
		# Rail-local transforms only reach as far as the rail; the carriage slides
		# along the rail's own Z, so in robot space it is a ray.
		axis_dirs.append(rail.basis.z)
		# Pulling the plate's joint centre back onto that ray is what leaves the
		# centre of the rod's sphere, and both ends of the subtraction hold still
		# until the rails move, so fold it in here.
		axis_zeros.append(
			rail.transform * Vector3(arm.position.x, arm.position.y, 0)
			- Basis(Vector3(0, 1, 0), deg_to_rad(thetas[i])) * Vector3(0, 0, params['inner_radius'])
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
	# plate's radial offset, which axis_zeros already carries.
	var a := axis_zeros[0] + axis_dirs[0] * q.x
	var b := axis_zeros[1] + axis_dirs[1] * q.y
	var c := axis_zeros[2] + axis_dirs[2] * q.z

	var plate_pos := trilaterate(a, b, c, params['rods_length'])
	if not plate_pos.is_finite():
		return  # axis combination outside the workspace
	plate.position = plate_pos

	# Each sphere centre is already the plate joint pulled back onto the
	# carriage, so the vector to it is the rod, at its full length by definition.
	aim_rods(0, plate_pos - a)
	aim_rods(1, plate_pos - b)
	aim_rods(2, plate_pos - c)


## Intersects three spheres of equal radius, returning the lower of the two
## solutions, or Vector3.INF if they do not meet.
func trilaterate(a: Vector3, b: Vector3, c: Vector3, radius: float) -> Vector3:
	var n1 := b - a
	var n2 := c - a
	var line := n1.cross(n2)
	var line_sq := line.length_squared()
	if line_sq < 1e-12:
		return Vector3.INF  # degenerate arrangement, the centres are collinear

	# Measured from `a`, equal radii reduce the other two spheres to the planes
	# n·x = |n|² / 2, and Cramer's rule against `line` (which is normal to both)
	# gives the one point of their intersection line closest to `a`.
	var point := (n2.cross(line) * n1.length_squared() + line.cross(n1) * n2.length_squared()) \
		/ (2.0 * line_sq)

	# That point is perpendicular to `line`, so the two solutions sit
	# symmetrically along it at the half chord of the sphere around `a`.
	var half_chord := radius * radius - point.length_squared()
	if half_chord < 0.0:
		return Vector3.INF
	# Dividing under the root rescales the step for `line` being unnormalised.
	half_chord = sqrt(half_chord / line_sq)
	return a + point + line * (-half_chord if line.y > 0.0 else half_chord)


## Swings a rail's rod pair, which run from their origins along local -Z, onto
## the given robot space direction.
func aim_rods(i: int, direction: Vector3) -> void:
	# rod_bases already divides by -rods_length, so this lands unit length.
	var z: Vector3 = rod_bases[i] * direction
	# The ball joints pivot around the arm's X axis, so keep the rod's own X as
	# close to it as the swing permits instead of letting the rod roll.
	var x := (Vector3(1, 0, 0) - z * z.x).normalized()
	var pose := Basis(x, z.cross(x), z)
	rods_l[i].basis = pose
	rods_r[i].basis = pose
