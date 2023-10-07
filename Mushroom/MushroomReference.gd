extends Node3D

@export var followTarget: Node3D

var offset

func _ready():
	offset = global_position - followTarget.global_position

func _process(delta):
	global_position = followTarget.global_position + offset
	if Input.is_key_pressed(KEY_Q):
		rotate_y(6 * delta)
	if Input.is_key_pressed(KEY_D):
		rotate_y(-6 * delta)
