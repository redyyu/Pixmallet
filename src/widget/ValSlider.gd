extends ProgressBar

class_name ValSlider

enum {
	NORMAL,
	HELD,
	SLIDING,
	TYPING,
}

var state = NORMAL
var mouse_start_pos :Vector2 = Vector2.ZERO
var last_value: float = 0
var last_ratio: float = 0.0
var overlayer :ColorRect = ColorRect.new()
var valueLineEdit :LineEdit
var slided_pressed :bool = false
var btn_pressed = false

@export var slide_by_step :bool = false
@export var slide_pressure :float = 1.0
@export var hidden_text :bool = false
@export var text_alignment :HorizontalAlignment
@export var prefix :String = ''
@export var suffix :String = ''
@export var spin_icon:Texture2D

@onready var valueSpinBox :SpinBox = SpinBox.new()


func _ready():
	show_percentage = false
	
	# spin box
	valueSpinBox.alignment = text_alignment
	valueSpinBox.prefix = prefix
	valueSpinBox.suffix = suffix
	valueSpinBox.min_value = min_value
	valueSpinBox.max_value = max_value
	valueSpinBox.value = value
	valueSpinBox.step = step
	valueSpinBox.exp_edit = exp_edit
	valueSpinBox.rounded = rounded
	valueSpinBox.allow_greater = allow_greater
	valueSpinBox.allow_lesser = allow_lesser
#	valueSpinBox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	valueSpinBox.set_anchors_preset(Control.PRESET_FULL_RECT)
	if spin_icon:
		valueSpinBox.add_theme_icon_override('updown', spin_icon)
	add_child(valueSpinBox)

	# for line edit of the spin box
	override_lineedit_stylebox(valueSpinBox)
	
	if hidden_text:
		valueSpinBox.hide()
	
	valueLineEdit = valueSpinBox.get_line_edit()
	valueLineEdit.gui_input.connect(_on_line_edit_gui_input)
	valueLineEdit.focus_exited.connect(_on_line_edit_focus_exit)
	
	overlayer.color = Color.TRANSPARENT
	overlayer.size = valueLineEdit.size
	overlayer.gui_input.connect(_on_overlayer_gui_input)
	overlayer.mouse_exited.connect(_on_overlayer_mouseout)
	add_child(overlayer)
	

func override_lineedit_stylebox(spinbox):
	var line_edit :LineEdit = spinbox.get_line_edit()
	for style_key in ['normal', 'focus', 'read_only']:
		var stylebox = line_edit.get_theme_stylebox(style_key).duplicate()
	#	_stylebox_normal.draw_center = false
		stylebox.bg_color = Color.TRANSPARENT
		stylebox.border_width_bottom = 0
		stylebox.border_width_top = 0
		stylebox.border_width_left = 0
		stylebox.border_width_right = 0
		line_edit.add_theme_stylebox_override(style_key, stylebox)
	line_edit.mouse_default_cursor_shape = Control.CURSOR_ARROW


func change_progress():
	
	var _distanc :float
	var _delta :float
	
	match fill_mode:
		FILL_BEGIN_TO_END:
			_delta = get_global_mouse_position().x - mouse_start_pos.x
			_distanc = size.x
		FILL_END_TO_BEGIN:
			_delta = mouse_start_pos.x - get_global_mouse_position().x
			_distanc = size.x
		FILL_TOP_TO_BOTTOM:
			_delta = get_global_mouse_position().y - mouse_start_pos.y
			_distanc = size.y
		FILL_BOTTOM_TO_TOP:
			_delta = mouse_start_pos.y - get_global_mouse_position().y
			_distanc = size.y
	
	if slide_by_step:
		value = last_value + (_delta * slide_pressure) * step
	else:
		ratio = last_ratio + _delta / _distanc


func _on_overlayer_gui_input(event: InputEvent):
	if (event is InputEventMouseButton):
		btn_pressed = event.pressed
	match state:
		NORMAL:
			if (event is InputEventMouseButton and btn_pressed and
				event.button_index == MOUSE_BUTTON_LEFT):
				state = HELD
				mouse_start_pos = get_global_mouse_position()
				last_value = value
				last_ratio = ratio
		HELD:
			if (event is InputEventMouseButton and btn_pressed and
				event.button_index == MOUSE_BUTTON_LEFT):
				state = TYPING
				overlayer.hide()
				valueSpinBox.get_line_edit().grab_focus()
			elif event is InputEventMouseMotion and btn_pressed:
				if mouse_start_pos.distance_to(get_global_mouse_position()) > 2:
					state = SLIDING
					print('SLIDING')
		SLIDING:
			if (event is InputEventMouseButton and not btn_pressed and
				event.button_index == MOUSE_BUTTON_LEFT):
				state = NORMAL
			elif event is InputEventMouseMotion and btn_pressed:
				change_progress()


func _on_overlayer_mouseout():
	if state == HELD:
		state = NORMAL	


func _on_line_edit_gui_input(event: InputEvent):
	if state == TYPING:
		if event is InputEventKey:
			print(event.keycode)
		if event is InputEventKey and event.keycode == KEY_ESCAPE:
			valueLineEdit.release_focus()


func _on_line_edit_focus_exit():
	state = NORMAL
	overlayer.show()
