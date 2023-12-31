class_name CropSizer extends GizmoSizer

signal applied(rect)
signal canceled


const MASK_COLOR := Color(0, 0, 0, 0.66)

var canvas_size := Vector2i.ZERO
var canvas_rect :Rect2i :
	get: return Rect2i(Vector2.ZERO, canvas_size)


func launch(size: Vector2i):
	reset()
	canvas_size = size
	var rect = Rect2i(Vector2i.ZERO, canvas_size)
	attach(rect)
	hire()


func apply():
	dismiss()
	applied.emit(bound_rect)


func cancel():
	bound_rect = Rect2i(Vector2i.ZERO, canvas_size)
	dismiss()
	canceled.emit()


func _draw():
	super._draw()
	
	if not has_area():
		return
	
	# Background
	if bound_rect.position.y > 0 and canvas_size.x > 0:
		var top_rect = canvas_rect.intersection(
			Rect2i(0, 0, canvas_size.x, bound_rect.position.y))
		draw_rect(top_rect, MASK_COLOR)
	
	if (canvas_size.x - bound_rect.end.x) > 0 and bound_rect.size.y > 0:
		var right_rect = canvas_rect.intersection(
			Rect2i(bound_rect.end.x, bound_rect.position.y, 
				   canvas_size.x - bound_rect.end.x, bound_rect.size.y))
		draw_rect(right_rect, MASK_COLOR)
	
	if canvas_size.x > 0 and (canvas_size.y - bound_rect.end.y) > 0:
		var bottom_rect = canvas_rect.intersection(
			Rect2i(0, bound_rect.end.y, 
				   canvas_size.x, canvas_size.y - bound_rect.end.y))
		draw_rect(bottom_rect, MASK_COLOR)	
		
	if bound_rect.position.x > 0 and bound_rect.size.y > 0:
		var left_rect = canvas_rect.intersection(
			Rect2i(0, bound_rect.position.y, 
				   bound_rect.position.x, bound_rect.size.y))
		draw_rect(left_rect, MASK_COLOR)

	# Horizontal rule of thirds lines:
	var third: float = bound_rect.position.y + bound_rect.size.y * 0.333
	draw_line(Vector2(bound_rect.position.x, third), 
			  Vector2(bound_rect.end.x, third),
			  line_color)
			
	third = bound_rect.position.y + bound_rect.size.y * 0.667
	draw_line(Vector2(bound_rect.position.x, third),
			  Vector2(bound_rect.end.x, third),
			  line_color)

	# Vertical rule of thirds lines:
	third = bound_rect.position.x + bound_rect.size.x * 0.333
	draw_line(Vector2(third, bound_rect.position.y),
			  Vector2(third, bound_rect.end.y),
			  line_color)
			
	third = bound_rect.position.x + bound_rect.size.x * 0.667
	draw_line(Vector2(third, bound_rect.position.y),
			  Vector2(third, bound_rect.end.y),
			  line_color)


func _input(event :InputEvent):
	# TODO: the way handle the events might not support touch / tablet. 
	# since I have no device to try. leave it for now.

	if not visible:
		return
			
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_ENTER) and \
		   event.is_command_or_control_pressed():
			apply()
		elif Input.is_key_pressed(KEY_ESCAPE):
			cancel()
	
	super._input(event)
