@tool
class_name OldFabrikIK
extends Node

const ITERATIONS := 5
const ERROR := 0.05

@export var skeleton: Skeleton3D
@export var root_bone: StringName
@export var tip_bone: StringName
@export var target_node: Node3D

var _bones: Array[IKBone] = []

func _ready():
	var tip := skeleton.find_bone(tip_bone)
	var root := skeleton.find_bone(root_bone)
	# Retrieve all bones
	var previous_pos := skeleton.get_bone_global_pose(tip).origin
	var current := skeleton.get_bone_parent(tip)
	while current != -1:
		var bone = IKBone.new()
		bone.id = current
		bone.name = skeleton.get_bone_name(current)
		bone.pose = skeleton.get_bone_global_pose(current)
		bone.original_pose = skeleton.get_bone_global_pose_no_override(current)
		bone.length = bone.pose.origin.distance_to(previous_pos)
		_bones.append(bone)
		if current == root:
			break
		previous_pos = bone.pose.origin
		current = skeleton.get_bone_parent(current)
	_bones.reverse()
	
	for bone in _bones:
		print(bone.name + " " + str(bone.pose.origin))

	_run_ik()
	_apply_ik()
		
func _process(delta):
	_run_ik()
	_apply_ik()

func _run_ik():
	var target = skeleton.global_transform.inverse() * target_node.global_transform
	var base = skeleton.get_bone_global_pose(_bones[0].id)
	for it in range(ITERATIONS):
		# Get target transform relative to skeleton
		_backward_pass(target)
		_forward_pass(base)
		_apply_rotation(target)

func _apply_ik():
	for bone in _bones:
		skeleton.set_bone_global_pose_override(bone.id, bone.pose, 1, true)

func _backward_pass(target: Transform3D):
	var i = _bones.size() - 1
	_bones[i].pose = target
	while i > 0:
		var prev = _bones[i]
		i -= 1
		var curr = _bones[i]
		var r = prev.pose.origin - curr.pose.origin
		var l = curr.length / r.length()
		
		var min_angle = Vector2(-10, 0)
		var max_angle = Vector2(10, 0)
		#l = clamp(l, min_angle, max_angle)
		
		curr.pose.origin = prev.pose.origin.lerp(curr.pose.origin, l)
	
func _forward_pass(base: Transform3D):
	_bones[0].pose = base
	for i in range(_bones.size() - 1):
		var curr = _bones[i]
		var next = _bones[i + 1]
		var r = next.pose.origin - curr.pose.origin
		var l = curr.length / r.length()
		
		var min_angle = Vector3(-10, 0, 0)
		var max_angle = Vector3(10, 0, 0)
		#l = clamp(l, -10, 30)
		
		next.pose.origin = curr.pose.origin.lerp(next.pose.origin, l)
		
func _apply_rotation(target: Transform3D):
	for i in range(_bones.size() - 2):
		var curr = _bones[i]
		var next = _bones[i + 1]
		
		var forward = (next.original_pose.origin - curr.original_pose.origin).normalized()
		var dir = next.pose.origin.direction_to(curr.pose.origin)
		var axis = forward.cross(dir).normalized()
		var dot = forward.dot(dir)
		dot = clamp(dot, -1, 1)
		var angle = acos(dot)
		var basis = Basis(axis, angle)
		curr.pose.basis = basis
