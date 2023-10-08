extends Node3D

@export var target: Node3D

var offset

func _ready():
	offset = global_position - target.global_position
	
func _process(delta):
	global_position = target.global_position + offset
