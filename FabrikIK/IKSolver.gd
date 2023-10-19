@tool
class_name IKSolver
extends Node

const ITERATIONS := 5
const ERROR := 0.05

@export var root_node: Node3D

var _ik_chains: Array[IKChain] = []

func _ready():
	# Retrieve child IK Chains
	for child in get_children():
		if child is IKChain:
			print("IK Chain added: " + child.name)
			_ik_chains.append(child)

func _process(delta):
	var root_pos = root_node.global_position
	for chain in _ik_chains:
		for it in range(ITERATIONS):
			chain.backward_pass()
			var err = chain.forward_pass(root_pos)
			if err < ERROR:
				break
		chain.apply_ik()
