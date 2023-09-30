class_name Enemy
extends KinematicBody2D

export (float) var speed := 100.0
var health := 10
var velocity := Vector2.ZERO

onready var player: KinematicBody2D

signal shoot_bullet(direction, bullet_position)

func _physics_process(_delta):
	var direction := player.global_position - global_position
	velocity = move_and_slide(direction.normalized() * speed)

func hit() -> void:
	health -= 1
	if health <= 0:
		queue_free()

func _on_ShootTimer_timeout():
	emit_signal('shoot_bullet', Vector2(player.global_position - global_position).rotated(randf()*0.2-0.1), global_position)

func _on_Detector_hit():
	hit()
