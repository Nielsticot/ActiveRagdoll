extends Node
class_name CCDIK

const ITERATIONS = 5
const ERROR = 0.05

@export var skeleton: Skeleton3D
@export var rootBone: StringName
@export var tipBone: StringName
@export var target: Node3D

var tipId
var bones: Array = []
var boneCount: int = 0

func _ready():
	tipId = skeleton.find_bone(tipBone)
	var rootId = skeleton.find_bone(rootBone)
	
	# Retrieve all bones
	var currentId = tipId
	while currentId != rootId:
		currentId = skeleton.get_bone_parent(currentId)
		bones.append(currentId)
	bones.reverse()
	boneCount = bones.size()
		
func _process(delta):
	if skeleton.get_bone_global_pose(tipId).origin.distance_to(target.position) < ERROR:
		return
	for i in range(ITERATIONS):
		for index in range(boneCount):
			evaluateBone(index)
			
func evaluateBone(index: int):
	var boneId = bones[index]
	var joint = skeleton.get_bone_global_pose(boneId)
	var effector = skeleton.get_bone_global_pose(tipId)
	var directionToEffector = (effector.origin - joint.origin).normalized()
	var directionToTarget = (target.global_position - joint.origin).normalized()
	var rotation = quaternionFromToRotation(directionToEffector, directionToTarget)
	skeleton.set_bone_pose_rotation(boneId, rotation)

func quaternionFromToRotation(from_vector: Vector3, to_vector: Vector3) -> Quaternion:
	from_vector = from_vector.normalized()
	to_vector = to_vector.normalized()

	var dot = from_vector.dot(to_vector)
	var cross = from_vector.cross(to_vector)

	var half_angle = acos(dot) / 2
	var sin_half_angle = sin(half_angle)
	var axis = cross.normalized()

	return Quaternion(axis, half_angle * 2)

func quaternionClampEuler(quaternion: Quaternion, minLimit: Vector3, maxLimit: Vector3) -> Quaternion:
	var euler = quaternion.get_euler()
	euler.clamp(minLimit, maxLimit)
	return Quaternion.from_euler(euler)
