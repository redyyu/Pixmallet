class_name Navbar extends Panel

signal navigation_to(nav_id, data)

enum {
	NEW_FILE, OPEN_FILE, RECENT_FILE, SAVE_FILE, SAVE_FILE_AS, EXPORT_FILE, QUIT,
	
	UNDO, REDO, COPY, CUT, PASTE, DELETE, 
	FILL_FOREGROUND, FILL_BACKGROUND,
	ZOOM_IN, ZOOM_OUT,
	PREFERENCES, 
	
	SELECT_ALL, CLEAR_SEL, INVERT_SEL,
	
	CROP_CANVAS, GRADIENT, IMG_OFFSET, IMG_SCALE, IMG_CROP, IMG_FLIP, IMG_ROTATE, 
	IMG_OUTLINE, IMG_DROP_SHADOW, IMG_INVERT_COLOR, IMG_DESATURATION, 
	IMG_HSV, IMG_POSTERIZE, 
	
	TILE_MODE, TILE_MODE_OFFSET, GRAYSCALE_VIEW, MIRROR_VIEW,
	SHOW_CARTESIAN_GRID, SHOW_ISOMETRIC_GRID, SHOW_PIX_GRID, 
	SHOW_RULERS, SHOW_GUIDES, SHOW_MOUSE_GUIDES, SHOW_SYMMETRY_GRID, 
	
	SNAP_GROUP, SNAP_GRID_CENTER, SNAP_GRID_BOUNDARY, 
	SNAP_GUIDES, SNAP_SYMMETRY_GRID, SNAP_PRESPECTIVE,
	
	TOOLBAR, TIMELINE, CANVAS_PREVIEW,
	COLOR_PICKER, TOOL_OPTION, REFERENCE_IMAGE, PRESPECTIVE,
	
	SPLASH, SUPPORT, LOG_FOLDER, ABOUT,
}

var menu_item_map: Dictionary = {}


@onready var navbar_keymaps = [
	{
		'menu': $MenuItems/File,
		'popmenus': [
			{'id': NEW_FILE, 'label': 'New', 'action': 'new_file', 
			 'event': KeyChain.makeEventKey(KEY_N, true)},
			{'id': OPEN_FILE, 'label':'Open', 'action': 'open_file',
			 'event': KeyChain.makeEventKey(KEY_O, true)},
			{'id': RECENT_FILE, 'label': 'Recent projects',
			 'submenu': $Submenu.duplicate(), 'unified': true, 'data': [
				{'label': 'file_path_1.file', 'path': 'file_path_1.file'},
				{'label': 'file_path_2.file', 'path': 'file_path_2.file'},
				{'label': 'file_path_2.file', 'path': 'file_path_2.file'},
			]},
			{'id': SAVE_FILE, 'label': 'Save', 'action': 'save',
			 'event': KeyChain.makeEventKey(KEY_S, true)},
			{'id': SAVE_FILE_AS, 'label': 'Save as', 'action': 'save_as',
			 'event': KeyChain.makeEventKey(KEY_S, true, true)},
			{'id': EXPORT_FILE, 'label': 'Export', 'action': 'export',
			 'event': KeyChain.makeEventKey(KEY_S, true, true, true)},
			{'id': QUIT, 'label': 'Quit', 'action': 'quit',
			 'event': KeyChain.makeEventKey(KEY_Q, true)},
		]
	},
	{
		'menu': $MenuItems/Edit,
		'popmenus': [
			{'id': UNDO, 'label': 'Undo', 'action': 'undo',
			 'event': KeyChain.makeEventKey(KEY_Z, true)},
			{'id': REDO, 'label':'Redo', 'action': 'redo',
			 'event': KeyChain.makeEventKey(KEY_Z, true, true)},
			{'id': COPY, 'label': 'Copy', 'action': 'copy',
			 'event': KeyChain.makeEventKey(KEY_C, true)},
			{'id': CUT, 'label': 'Cut', 'action': 'cut',
			 'event': KeyChain.makeEventKey(KEY_X, true)},
			{'id': PASTE, 'label': 'Paste', 'action': 'paste',
			 'event': KeyChain.makeEventKey(KEY_V, true)},
			{'id': DELETE, 'label': 'Delete', 'action': 'delete',
			 'event': KeyChain.makeEventKey(KEY_BACKSPACE)},
			{'separate': true},
			{'id': FILL_FOREGROUND, 'label': 'Fill Foreground', 
			 'action': 'fill_foreground',
			 'event': KeyChain.makeEventKey(KEY_BACKSPACE, true)},
			{'id': FILL_BACKGROUND, 'label': 'Fill Background', 
			 'action': 'fill_Backround',
			 'event': KeyChain.makeEventKey(KEY_BACKSPACE, true, true)},
			{'separate': true},
			{'id': ZOOM_IN, 'label': 'Zoom In', 'action': 'zoom_in',
			 'event': KeyChain.makeEventKey(KEY_EQUAL, true)},
			{'id': ZOOM_OUT, 'label': 'Zoom Out', 'action': 'zoom_out',
			 'event': KeyChain.makeEventKey(KEY_MINUS, true)},
			{'separate': true},
			{'id': PREFERENCES, 'label': 'Preferences'},
		]
	},
	{
		'menu': $MenuItems/Select,
		'popmenus': [
			{'id': SELECT_ALL, 'label': 'All', 'action': 'select_all',
			 'event': KeyChain.makeEventKey(KEY_A, true)},
			{'id': CLEAR_SEL, 'label':'Clear', 'action': 'deselect',
			 'event': KeyChain.makeEventKey(KEY_D, true)},
			{'id': INVERT_SEL, 'label': 'Invert', 'action': 'invert_selection',
			 'event': KeyChain.makeEventKey(KEY_I, true, true)},
#			{'key': 'tile_selection', 'label': 'On Tile'},
		]
	},
	{
		'menu': $MenuItems/Modify,
		'popmenus': [
			{'id': CROP_CANVAS, 'label': 'Crop Canvas',
			 'action': 'crop_canvas'},
			{'id': IMG_CROP, 'label': 'Crop to Image Edge',
			 'action': 'crop_to_image'},
			{'id': IMG_OFFSET, 'label':'Offset Image',
			 'action': 'offset_image'},
			{'id': IMG_SCALE, 'label': 'Scale Image',
			 'action': 'scale_image'},
			{'id': IMG_FLIP, 'label': 'Flip Image',
			 'action': 'flip_image'},
			{'id': IMG_ROTATE, 'label': 'Rotate Image',
			 'action': 'rotate_image'},
			{'id': IMG_OUTLINE, 'label': 'Outline',
			 'action': 'outline'},
			{'id': IMG_DROP_SHADOW, 'label': 'Drop Shadow',
			 'action': 'drop_shadow'},
			{'id': IMG_INVERT_COLOR, 'label': 'Invert Colors',
			 'action': 'invert_color'},
			{'id': IMG_DESATURATION, 'label': 'Desaturation',
			 'action': 'desaturation'},
			{'id': IMG_HSV, 'label': 'Hue/Saturation/Value',
			 'action': 'hsv'},
			{'id': IMG_POSTERIZE, 'label': 'Posterize',
			 'action': 'postersize'},
			{'id': GRADIENT, 'label': 'Gradient',
			 'action': 'gradient'},
		]
	},
	{
		'menu': $MenuItems/View,
		'popmenus': [
			{'id': TILE_MODE, 'label': 'Tile Mode', 'action': 'tile_mode'},
			{'id': TILE_MODE_OFFSET, 'label':'Tile Mode Offset', 
			 'action': 'tile_mode_offset'},
			{'id': GRAYSCALE_VIEW, 'label': 'Grayscale View',
			 'action': 'grayscale_view', 'checked': false},
			{'id': MIRROR_VIEW, 'label': 'Mirror View',
			 'action': 'mirror_view', 'checked': false},
			{'id': SHOW_CARTESIAN_GRID, 'label': 'Show Cartesian Grid',
			 'action': 'show_cartesian_grid', 'checked': false,
			 'event': KeyChain.makeEventKey(KEY_COMMA, true)},
			{'id': SHOW_ISOMETRIC_GRID, 'label': 'Show Isometric Grid', 
			 'action': 'show_isometric_grid', 'checked': false,
			 'event': KeyChain.makeEventKey(KEY_STOP, true)},
			{'id': SHOW_PIX_GRID, 'label': 'Show Pixel Grid',
			 'action': 'show_pixel_grid', 'checked': false,
			 'event': KeyChain.makeEventKey(KEY_SLASH, true)},
			{'id': SHOW_RULERS, 'label': 'Show Rulers',
			 'action': 'show_rulerss', 'checked': true,
			 'event': KeyChain.makeEventKey(KEY_R, true)},
			{'id': SHOW_GUIDES, 'label': 'Show Guides', 
			 'action': 'show_guides', 'checked': true,
			 'event': KeyChain.makeEventKey(KEY_SEMICOLON, true)},
			{'id': SHOW_SYMMETRY_GRID, 'label': 'Show Symmetry Guides', 
			 'action': 'show_sysmmetry_grid', 'checked': false,
			 'event': KeyChain.makeEventKey(KEY_APOSTROPHE, true)},
			{'id': SHOW_MOUSE_GUIDES, 'label': 'Show Mouse Guides',
			 'action': 'show_mouse_guides', 'checked': false},
			{'id': SNAP_GROUP, 'label': 'Snap To', 
			 'submenu': $Submenu.duplicate(),
			 'data': [
				{'id': SNAP_GRID_CENTER, 'label':'Grid Center', 'checked': false,
				 'action': 'snap_to_grids_center'},
				{'id': SNAP_GRID_BOUNDARY, 'label':'Grid Boundary', 'checked': false,
				 'action': 'snap_to_grids_boundary'},
				{'id': SNAP_SYMMETRY_GRID, 'label':'Symmetry Grid', 'checked': false,
				 'action': 'snap_to_grids_boundary'},
				{'id': SNAP_GUIDES, 'label':'Guides', 'checked': false,
				 'action': 'snap_to_guides'},
#				{'id': SNAP_PRESPECTIVE, 'label':'Perspective Guides',
#				 'checked': false, 'action': 'snap_to_perspective'}
			]},
		]
	},
	{
		'menu': $MenuItems/Window,
		'popmenus': [
#			{'key': 'toogle_canvas_only', 'label': 'Toogle Canvas Only'},
			{'id': TOOLBAR, 'label': 'Tools', 'checked': true},
			{'id': TIMELINE, 'label': 'Animation Timeline', 'checked': true},
			{'id': CANVAS_PREVIEW, 'label': 'Canvas Preview', 'checked': true},
			{'id': COLOR_PICKER, 'label': 'Color Pickers', 'checked': true},
			{'id': TOOL_OPTION, 'label': 'Tool Options', 'checked': true},
			{'id': REFERENCE_IMAGE, 'label': 'Reference Images'},
#			{'id': PRESPECTIVE, 'label': 'Perspective Editor', 'checked': false},
		]
	},
	{
		'menu': $MenuItems/Help,
		'popmenus': [
			{'id': SPLASH, 'label': 'Splash Screen'},
			{'id': SUPPORT, 'label':'Support'},
			{'id': LOG_FOLDER, 'label': 'Logs'},
			{'id': ABOUT, 'label': 'About'},
		]
	}
]


func launch():
	for menu in navbar_keymaps:
		set_menu_items(menu['menu'], menu['popmenus'])


func set_menu_items(menu:MenuButton, structure:Array):
	var menu_popup = menu.get_popup()
	menu_popup.id_pressed.connect(_on_menu_id_pressed)
	
	for i in structure.size():
		var item = structure[i]
		if item.get('submenu'):
			var rediect_id = item['id'] if item.get('unified') else -1
			item['submenu'].register(item['label'], item.get('data', []),
									 menu_popup, rediect_id)
		elif item.get('separate'):
			menu_popup.add_separator()
			continue
		elif item.has('id'):
			if item.has('checked'):
				menu_popup.add_check_item(item['label'], item['id'])
				menu_popup.set_item_checked(i, bool(item['checked']))
				menu_popup.hide_on_checkable_item_selection = false
				if item.get('checked') == true:
					# emit singal to trigger the checked
					navigation_to.emit(item['id'], item)
			else:
				menu_popup.add_item(item['label'], item['id'])
				
			if item.get('action'):
				var shortcut:Shortcut = Shortcut.new()
				var event:InputEventAction = InputEventAction.new()
				event.action = item['action']
				shortcut.events.append(event)
				var action = keyChain.add_action(item['action'], 
												 item['label'], 
												 name)
				if item.get('event'):
					action.bind_event(item['event'])
				menu_popup.set_item_shortcut(i, shortcut)
		
		# record menu item to k, v map
		item['popup'] = menu_popup
		item['index'] = i
		menu_item_map[item['id']] = item


func _on_menu_id_pressed(item_id):
	var item_data = menu_item_map.get(item_id)
	var menu_popup = item_data['popup']
	var idx = item_data['index']
	
	if item_data.has('checked'):
		item_data['checked'] = not item_data.get('checked')
		menu_popup.set_item_checked(idx, item_data['checked'])
	
	navigation_to.emit(item_id, item_data)


func _on_submenu_item_pressed(item_id, item_data):
	navigation_to.emit(item_id, item_data)
