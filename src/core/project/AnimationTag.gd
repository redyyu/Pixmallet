extends RefCounted

class_name AnimationTag
# A class for frame tag properties

var name: String
var color: Color
var from: int
var to: int


func _init(_name, _color, _from, _to):
	name = _name
	color = _color
	from = _from
	to = _to


func update(_name, _color, _from, _to):
	name = _name
	color = _color
	from = _from
	to = _to
