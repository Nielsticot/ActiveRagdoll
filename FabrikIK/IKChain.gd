@tool
class_name IKChain
extends Node

## Target skeleton
@export var skeleton: Skeleton3D
## First bone of IK Chain
@export var root_bone: StringName
## The last bone of IK Chain
@export var tip_bone: StringName

var _points: Array[IKPoint] = []
var _target_node: Node
var _target_pos: Vector3 = Vector3.ZERO
var _tip_pos: Vector3 = Vector3.ZERO
var _tip_id: int = -1

func _ready():
	# Get target
	_target_node = get_child(0)
	
	# Initialize IK Points
	_tip_id = skeleton.find_bone(tip_bone)
	var root_id = skeleton.find_bone(root_bone)
	var root_parent_id = skeleton.get_bone_parent(root_id)
	
	_tip_pos = skeleton.get_bone_global_pose(_tip_id).origin
	var previous_pos = _tip_pos
	var current_id = skeleton.get_bone_parent(_tip_id)
	while current_id != root_parent_id:
		var ik_point = IKPoint.new()
		ik_point.bone_id = current_id
		ik_point.bone_name = skeleton.get_bone_name(current_id)
		ik_point.original_bone_pose = skeleton.get_bone_global_pose_no_override(current_id)
		ik_point.position = skeleton.get_bone_global_pose(current_id).origin
		ik_point.length = ik_point.position.distance_to(previous_pos)
		_points.append(ik_point)
		previous_pos = ik_point.position
		current_id = skeleton.get_bone_parent(ik_point.bone_id)
	_points.reverse()


## Get target position for backward pass from first child node or position of target node
func _compute_target_pos():
	if _target_node is Node3D:
		# Get position relative to skeleton
		_target_pos = skeleton.global_transform.inverse() * _target_node.global_position
	if _target_node is IKBase:
		# Get centroid from backard pass of IK Base
		_target_pos = _target_node.backward_pass()


## Run backward pass and return new position of root bone
func backward_pass() -> Vector3:
	_compute_target_pos()
	
	_tip_pos = _target_pos
	var prev_pos = _tip_pos
	for i in range(_points.size() - 1, -1, -1):
		var curr = _points[i]
		var r = prev_pos - curr.position
		var l = curr.length / r.length()
		curr.position = prev_pos.lerp(curr.position, l)
		prev_pos = curr.position
	return _points[0].position


## Run forward pass and return distance from target
func forward_pass(position: Vector3) -> float:
	_points[0].position = skeleton.global_transform.inverse() * position
	for i in range(_points.size() - 1):
		var curr = _points[i]
		var next = _points[i + 1]
		var r = next.position - curr.position
		var l = curr.length / r.length()
		next.position = curr.position.lerp(next.position, l)
	var last = _points[-1]
	var r = _tip_pos - last.position
	var l = last.length / r.length()
	_tip_pos = last.position.lerp(_tip_pos, l)
	return _tip_pos.distance_to(_target_pos)


## Apply IK to the skeleton's bones
func apply_ik():
	# Move bones
	for i in range(1, _points.size()):
		var point = _points[i]
		var pos = point.original_bone_pose
		pos.origin = point.position
		skeleton.set_bone_global_pose_override(point.bone_id, pos, 1, true)
	# Move tip bone
	var pos = Transform3D.IDENTITY
	pos.origin = _tip_pos
	skeleton.set_bone_global_pose_override(_tip_id, pos, 1, true)
