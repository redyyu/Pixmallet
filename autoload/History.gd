class_name History extends Node

var undo_redo = UndoRedo.new()
var count :int :
	get: return undo_redo.get_history_count()
var current_action_id :int :
	get: return undo_redo.get_current_action()
var version : int:
	get: return undo_redo.get_version()

var properties_stack :Array[HistoryProp] = []
var do_methods_stack :Array[Callable] = []
var undo_methods_stack :Array[Callable] = []

var default_callbacks :Dictionary = {}


func clear_history():
	undo_redo.clear_history()
	

func reset():
	properties_stack.clear()
	do_methods_stack.clear()
	undo_methods_stack.clear()


func register_default_callbacks(_callbacks_map :Dictionary):
	for k in _callbacks_map:
		var callback = _callbacks_map[k]
		if (k is String or k is StringName) and callback is Callable:
			if k in ['_', '-', '*']:
				k = '_'
			default_callbacks[k] = callback


func unregister_default_callbacks():
	default_callbacks.clear()


func record(properties:Variant, actions:Variant=null, use_reset:=true):
	if use_reset:
		reset()
	
	for prop in prepare_properties(properties):
		properties_stack.append(prop)

	for act in prepare_methods(actions):
		match act.type:
			HistoryMethod.Type.DO:
				do_methods_stack.append(act.method)
			HistoryMethod.Type.UNDO:
				undo_methods_stack.append(act.method)
			_:
				do_methods_stack.append(act.method)
				undo_methods_stack.append(act.method)


func commit(action_name:StringName = '', actions = null, properties = null):
	if properties != null or actions != null:
		# append prop and actions
		record(properties, actions, false)
	
	undo_redo.create_action(action_name)
	
	for prop in properties_stack:
		undo_redo.add_do_property(prop.obj, prop.key, prop.do_value)
	
	for prop in properties_stack:
		undo_redo.add_undo_property(prop.obj, prop.key, prop.undo_value)
	
	var callbacks = get_default_callbacks(action_name)
	
	for do_act in do_methods_stack:
		undo_redo.add_do_method(do_act)
	
	for c in callbacks:
		undo_redo.add_do_method(c)
	
	for undo_act in undo_methods_stack:
		undo_redo.add_undo_method(undo_act)
	
	for c in callbacks:
		undo_redo.add_undo_method(c)

	undo_redo.commit_action(false)
	reset()


func undo():
	if undo_redo.has_undo():
		undo_redo.undo()


func redo():
	if undo_redo.has_redo():
		undo_redo.redo()


func prepare_properties(objs:Variant):
	var props :Array = []
	if objs is Image or objs is Dictionary:
		objs = [objs]
	elif not objs is Array:
		return props
	for obj in objs:
		if obj is Image:
			props.append(HistoryProp.new(obj, 'data'))
		elif obj is Dictionary:
			var prop = HistoryProp.new(obj['obj'], obj['key'])
			if obj.has('undo'):
				prop.undo_value = obj.get('undo')
			props.append(prop)
	return props


func prepare_methods(actions:Variant):
	var methods :Array = []
	
	if actions is Callable or actions is Dictionary:
		actions = [actions]
	elif not actions is Array:
		return methods
	
	for act in actions:
		if act is Callable:
			methods.append(HistoryMethod.new(act))
		elif act is Dictionary:
			var method_type = HistoryMethod.Type.ALL
			if act.get('is_do'):
				method_type = HistoryMethod.Type.DO
			if act.get('is_undo'):
				method_type = HistoryMethod.Type.UNDO
			methods.append(HistoryMethod.new(act['action'], method_type))
	return methods


func get_default_callbacks(key):
	var output := []
	for k in default_callbacks:
		if k == '_' or key.begins_with(key):
			output.append(default_callbacks[k])
	return output


func gen_action_name():
	return '{}-{}'.format([Time.get_unix_time_from_system(),
						   randi_range(1000, 9999)], '{}')


class HistoryProp extends Object:
	
	var obj :Variant
	var key :StringName
	var undo_value :Variant
	var do_value :Variant :
		get: return obj.get(key)
	
	func _init(_obj :Variant, _key :StringName):
		obj = _obj
		key = _key
		undo_value = obj.get(key)


class HistoryMethod extends Object:
	
	enum Type {
		ALL,
		DO,
		UNDO,
	}
	
	var method :Callable
	var type := Type.ALL
	
	func _init(_method :Callable, _type := Type.ALL):
		method = _method
		type = _type
