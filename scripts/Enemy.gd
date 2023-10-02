class_name Enemy
extends KinematicBody2D

export (float) var speed := 100.0
var health := 10.0
var velocity := Vector2.ZERO

onready var player: KinematicBody2D

signal shoot_bullet(direction, bullet_position)
signal spawn_orb(position)


func _ready():
	$Sprite.material = $Sprite.material.duplicate(true)


func _physics_process(_delta):
	var direction := player.global_position - global_position
	velocity = move_and_slide(direction.normalized() * speed)


func _on_ShootTimer_timeout():
	shoot()


func shoot() -> void:
	emit_signal('shoot_bullet', Vector2(player.global_position - global_position).rotated(randf()*0.2-0.1), global_position)


func _on_Detector_hit():
	hit()


func hit(damage = 1.0) -> void:
	health -= damage
	$AnimationPlayer.play("hit_flash")
	if health <= 0:
		emit_signal('spawn_orb', global_position)
		Globals.add_score()
		queue_free()


func damage_over_time(damage) -> void:
	health -= damage
	$AnimationPlayer.play("hit_flash")
	if health <= 0:
		emit_signal('spawn_orb', global_position)
		Globals.add_score()
		queue_free()
