extends Skeleton3D

@export var freefall: bool = false
@export var target_skeleton: Skeleton3D
@export var physical_bones: Node
@export var angular_spring_stiffness: float = 4000.0
@export var angular_spring_damping: float = 80.0
@export var max_angular_force: float = 9999.0

var physics_bones

func _ready():
	physical_bones_start_simulation()
	physics_bones = physical_bones .get_children()

func _physics_process(delta):
	if not freefall:
		for b in physics_bones:
			var target_transform: Transform3D = target_skeleton.global_transform * target_skeleton.get_bone_global_pose(b.get_bone_id())
			var current_transform: Transform3D = global_transform * get_bone_global_pose(b.get_bone_id())
			var rotation_difference: Basis = (target_transform.basis * current_transform.basis.inverse())
			
			var torque = hookes_law(rotation_difference.get_euler(), b.angular_velocity, angular_spring_stiffness, angular_spring_damping)
			torque = torque.limit_length(max_angular_force)
			
			b.angular_velocity += torque * delta

func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)
