class_name IKBase
extends Node

## Get references of child IK Chains
func _ready():
	pass

# Returns the centroid of child chains
func backward_pass() -> Vector3:
	return Vector3.ZERO

func forward_pass(position: Vector3):
	pass
