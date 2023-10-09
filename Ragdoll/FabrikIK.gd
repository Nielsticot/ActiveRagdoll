extends Node
class_name FabrikIK

@export var skeleton: Skeleton3D
@export var rootBone: StringName
@export var tipBone: StringName
@export var target: Node3D

var bones: Array[float] = []
var bonesLength: Array[float] = []
var boneCount: int = 0

func _ready():
	var tip = skeleton.find_bone(tipBone)
	var root = skeleton.find_bone(rootBone)
	var current = tip
	while current != root:
		var previousPos = skeleton.get_bone_global_pose(current).origin
		current = skeleton.get_bone_parent(current)
		var currentPos = skeleton.get_bone_global_pose(current).origin
		bonesLength.append(currentPos.distance_to(previousPos))
		bones.append(current)
	for length in bonesLength:
		print(length)

func _process(delta):
	pass
