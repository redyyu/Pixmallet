class_name Artboard extends SubViewportContainer


signal project_cropped(rect)
signal color_picked(color)


var state := Operate.NONE :
	set = set_state

var project :Project

var current_operator :Variant :
	get: return canvas.current_operator

var camera_offset :Vector2 :
	get: return camera.offset
	
var camera_zoom :Vector2 :
	get: return camera.zoom
	
var camera_origin :Vector2 :
	get: return Vector2(size * 0.5 - camera_offset * camera_zoom)

var guides :Array[Guide] = []
var guides_locked := false :
	set(val):
		guides_locked = val
#		_lock_guides(guides_locked or state != Operate.MOVE)
		_lock_guides(guides_locked)
		
var show_guides := false :
	set(val):
		show_guides = val
		for guide in guides:
			guide.visible = show_guides
		v_ruler.set_activate(show_guides)
		h_ruler.set_activate(show_guides)
		place_guides()


var show_pixel_grid :bool :
	get: return grid.show_pixel_grid
	set(val): 
		grid.show_pixel_grid = val
		place_grid()

var show_cartesian_grid :bool :
	get: return grid.show_cartesian_grid
	set(val): 
		grid.show_cartesian_grid = val
		place_grid()
		
var show_isometric_grid :bool :
	get: return grid.show_isometric_grid
	set(val): 
		grid.show_isometric_grid = val
		place_grid()

var show_symmetry_guide_state := SymmetryGuide.NONE :
	set(val):
		show_symmetry_guide_state = val
		symmetry_guide.state = show_symmetry_guide_state
		symmetry_guide.set_guide(size)
		place_symmetry_guides()

var show_mouse_guide := false:
	set(val):
		show_mouse_guide = val
		mouse_guide.visible = val
		mouse_guide.set_guide(size)

var show_rulers := false:
	set(val):
		show_rulers = val
		h_ruler.visible = val
		v_ruler.visible = val
		place_rulers()

var snap_to_guide :bool:
	set(val):
		canvas.snap_to_guide = val
	get: return canvas.snap_to_guide

var snap_to_grid_center :bool:
	set(val):
		canvas.snap_to_grid_center = val
	get: return canvas.snap_to_grid_center

var snap_to_grid_boundary :bool :
	set(val):
		canvas.snap_to_grid_boundary = val
	get: return canvas.snap_to_grid_boundary

var snap_to_symmetry_guide :bool :
	set(val):
		canvas.snap_to_symmetry_guide = val
	get: return canvas.snap_to_symmetry_guide

@onready var viewport :SubViewport = $Viewport
@onready var camera :Camera2D = $Viewport/Camera
@onready var canvas :Node2D = $Viewport/Canvas
@onready var trans_checker :ColorRect = $Viewport/TransChecker
@onready var reference_image :ReferenceImage = $Viewport/ReferenceImage
@onready var h_ruler :Button = $HRuler
@onready var v_ruler :Button = $VRuler

@onready var symmetry_guide :Node2D = $SymmetryGuide
@onready var mouse_guide :Node2D = $MouseGuide
@onready var grid :Node2D = $Viewport/Grid


func _ready():
	h_ruler.guide_created.connect(_on_guide_created)
	v_ruler.guide_created.connect(_on_guide_created)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	resized.connect(_on_artboard_resized)
	camera.dragged.connect(_on_camera_updated)
	camera.zoomed.connect(_on_camera_updated)
	camera.press_updated.connect(_on_camera_pressing)
	
	viewport.size_changed.connect(_on_viewport_size_changed)
	camera.viewport_size = viewport.size
	
	canvas.cursor_changed.connect(_on_canvas_cursor_changed)
	canvas.operating.connect(_on_canvas_operating)
	canvas.color_picked.connect(_on_canvas_color_picked)
	
	mouse_guide.set_guide(size)
	symmetry_guide.set_guide(size)
	
	state = Operate.NONE  # trggier options when state changed.


func load_project(proj :Project):
	project = proj
	
	reference_image.canvas_size = project.size
	grid.canvas_size = project.size
	
	camera.canvas_size = project.size
	camera.zoom_100()

	canvas.attach_project(project)
	canvas.attach_snap_to(project.size, guides, symmetry_guide, grid)
	trans_checker.update_bounds(project.size)


func set_state(val):
	# allow change without really changed val, trigger funcs in setter.
	state = val
	canvas.state = state
	camera.state = state
	change_state_cursor(state)
#		# NO NEED it
#		if state == Operate.MOVE:
#			_lock_guides(guides_locked)
#		else:
#			_lock_guides(true)


func change_state_cursor(curr_state):
	if curr_state == Operate.MOVE:
		mouse_default_cursor_shape = Control.CURSOR_MOVE
	elif curr_state == Operate.PAN: 
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	elif curr_state in [Operate.BRUSH, Operate.PENCIL, Operate.ERASE,
						Operate.COLORPICK, Operate.SHADING,
						Operate.SELECT_ELLIPSE, Operate.SELECT_RECTANGLE,
						Operate.SELECT_LASSO, Operate.SELECT_POLYGON,
						Operate.SELECT_MAGIC,
						Operate.SHAPE_ELLIPSE, Operate.SHAPE_LINE,
						Operate.SHAPE_POLYGON, Operate.SHAPE_RECTANGLE]:
		mouse_default_cursor_shape = Control.CURSOR_CROSS
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW


func set_current_color(color :Color):
	canvas.silhouette.shape_color = color
	canvas.bucket.fill_color = color
	canvas.drawer_pencil.stroke_color = color
	canvas.drawer_brush.stroke_color = color


# place lines

func place_grid():
	if project and [show_cartesian_grid, 
					show_isometric_grid,
					show_pixel_grid].any(func(s): return s == true):
		grid.zoom_at = camera.zoom.x


func place_symmetry_guides():
	if project and show_symmetry_guide_state != SymmetryGuide.NONE:
		symmetry_guide.move(project.size, camera_origin, camera_zoom)


func place_rulers():
	if project and show_rulers:
		h_ruler.set_ruler(size, project.size, camera_offset, camera_zoom)
		v_ruler.set_ruler(size, project.size, camera_offset, camera_zoom)


func place_guides():
	if project and show_guides:
		for guide in guides:
			match guide.orientation:
				HORIZONTAL:
					guide.position.y = camera_origin.y + \
						guide.relative_position.y * camera_zoom.y
				VERTICAL:
					guide.position.x = camera_origin.x + \
						guide.relative_position.x * camera_zoom.x


func get_selected_rect():
	return canvas.selection.selected_rect


# event handler

func _on_artboard_resized():
	_on_camera_updated() # do samething with camera changed.
	
	# no need to sheck show options, hiden will still be hidden,
	# but keep the size correct, even it is not showing up.
	
	mouse_guide.resize(size) 
	symmetry_guide.resize(size)
	
	for guide in guides:
		guide.resize(size)


func _on_camera_updated():
	place_rulers()
	place_guides()
	place_symmetry_guides()
	place_grid()
	canvas.zoom = camera_zoom
	

func _on_camera_pressing(is_pressed):
	if state == Operate.PAN:
		if is_pressed:
			mouse_default_cursor_shape = Control.CURSOR_DRAG
		else:
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _on_viewport_size_changed():
	camera.viewport_size = viewport.size


func _on_canvas_operating(_state:int, in_progress :bool):
	if in_progress:
		_lock_guides(true)
	else:
		_lock_guides(guides_locked)


func _on_canvas_cursor_changed(cursor):
	if cursor:
		mouse_default_cursor_shape = cursor
	else:
		change_state_cursor(state)


func _on_canvas_color_picked(color):
	color_picked.emit(color)


func _on_mouse_entered():
	camera.set_process_input(true)


func _on_mouse_exited():
	camera.set_process_input(false)


# guides
func _lock_guides(val :bool): # do not use it in other scopes.
	# for internal use, temporary lock guides while state switched.
	for guide in guides:
		guide.is_locked = val


func _on_guide_created(type):
	var guide = Guide.new()
	guide.set_guide(type, size)
	guides.append(guide)
	add_child(guide)
	guide.get_artboard_mouse_position = func():
		# for make sure position is from artboard when guide is dragging.
		return get_local_mouse_position()
	guide.pressed.connect(_on_guide_pressed)
	guide.released.connect(_on_guide_released)
	guide.hovered.connect(_on_guide_hovered)
	guide.leaved.connect(_on_guide_leaved)
	

func _on_guide_hovered(guide):
	for _guide in guides:
		if _guide != guide:
			_guide.is_hovered = false
	match guide.orientation:
		HORIZONTAL:
			mouse_default_cursor_shape = Control.CURSOR_VSPLIT
		VERTICAL:
			mouse_default_cursor_shape = Control.CURSOR_HSPLIT
	if not guide.is_locked:
		canvas.frozen()  # frozen canvas if guide is not locked.


func _on_guide_leaved(_guide):
	change_state_cursor(state)
	canvas.frozen(false)  # unfrozen canvas anyway.


func _on_guide_pressed(guide):
	# clear up other guide status
	for _guide in guides:
		if _guide != guide:
			_guide.is_pressed = false


func _on_guide_released(guide):
#	guide.is_locked = guides_locked or state != Operate.MOVE
	guide.is_locked = guides_locked
	
	guide.relative_position = canvas.get_relative_mouse_position()
	# take canvas local mouse position as rounded.
	# calculate to the relative position might not working precisely.
	# otherwise position might mess-up place guide while is zoomed and snapping.
	
	var sel_rect = get_selected_rect()
	
	match guide.orientation:
		HORIZONTAL:
			if guide.position.y < h_ruler.size.y:
				guide.pressed.disconnect(_on_guide_pressed)
				guide.released.disconnect(_on_guide_released)
				guides.erase(guide)
				guide.queue_free()
				mouse_default_cursor_shape = Control.CURSOR_ARROW
			elif sel_rect.has_area():
				guide.snap_to(sel_rect.position)
				guide.snap_to(sel_rect.position + sel_rect.size)
		VERTICAL:
			if guide.position.x < v_ruler.size.x:
				guide.pressed.disconnect(_on_guide_pressed)
				guide.released.disconnect(_on_guide_released)
				guides.erase(guide)
				guide.queue_free()
				mouse_default_cursor_shape = Control.CURSOR_ARROW
			elif sel_rect.has_area():
				guide.snap_to(sel_rect.position)
				guide.snap_to(sel_rect.position + sel_rect.size)
	
	# make sure guides is in place
	place_guides()
