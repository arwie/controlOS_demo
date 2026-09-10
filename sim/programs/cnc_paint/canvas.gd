extends Node3D

## Paints the trace of a tool tip onto a round canvas.


const canvas_size := 0.5              ## edge length of the quad, metres
const line_width := 10                ## trace width, canvas pixels
const step := 0.5                     ## shortest segment worth drawing, canvas pixels

@export var trace_color  := Color.BLACK
@export var canvas_color := Color.SKY_BLUE

@onready var tcp: Node3D = %robot/%tcp
@onready var viewport: SubViewport = $SubViewport
@onready var painter: Node2D = $SubViewport/Painter

var tool_tip := Vector3.ZERO          # the tip, in the TCP's own space
var last_point := Vector2.INF         # canvas pixel painted last, INF when lifted
var pending := PackedVector2Array()   # segment ends waiting for the next redraw
var blank_pending := true


## Wipes the canvas back to blank paint.
func clear() -> void:
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	blank_pending = true
	pending.clear()
	last_point = Vector2.INF
	repaint()


func _ready() -> void:
	tool_tip = tip_of(tcp)
	painter.draw.connect(_on_painter_draw)
	clear()


## How far the tool hanging on a node reaches below it, on the node's own axis.
## Measuring against the TCP rather than the world keeps the tip put however the
## robot is posed. With no tool the tip is the mount itself.
func tip_of(node: Node3D) -> Vector3:
	var to_node := node.global_transform.affine_inverse()
	var depth := 0.0
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		var box := to_node * mesh.global_transform * mesh.get_aabb()
		depth = minf(depth, box.position.y)
	return Vector3(0, depth, 0)


func _process(_delta: float) -> void:
	var local := to_local(tcp.global_transform * tool_tip)
	if local.y > 0.0:
		last_point = Vector2.INF  # lifted, the next touch starts a new stroke
		return

	# Metres across the quad -> UV from its corner -> texel of the square viewport.
	var point: Vector2 =  (Vector2(local.x, local.z) / canvas_size + Vector2(0.5, 0.5)) * viewport.size.x

	if last_point != Vector2.INF and last_point.distance_squared_to(point) < step * step:
		return

	pending.append(point if last_point == Vector2.INF else last_point)
	pending.append(point)
	last_point = point
	repaint()


func repaint() -> void:
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	painter.queue_redraw()


func _on_painter_draw() -> void:
	if blank_pending:
		blank_pending = false
		var radius := viewport.size.x * 0.5
		painter.draw_circle(Vector2(radius, radius), radius, canvas_color)

	for i in range(0, pending.size(), 2):
		var from := pending[i]
		var to := pending[i + 1]
		if from != to:
			painter.draw_line(from, to, trace_color, line_width, true)
		# Round off the joint, so a change of direction leaves no notch.
		painter.draw_circle(to, line_width * 0.5, trace_color)
	pending.clear()
