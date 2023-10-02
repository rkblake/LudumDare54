extends Sprite

export (NodePath) var player_path; onready var player = get_node(player_path) as KinematicBody2D

func _physics_process(delta):
	self.global_position.x = floor(player.position.x / 64) * 64
	self.global_position.y = floor(player.position.y / 64) * 64
