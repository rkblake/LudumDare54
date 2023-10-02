class_name Detector
extends Area2D

var detecting := true
export (bool) var player
export (float) var iframes = 0.1

onready var player_bullet_spawner = get_tree().root.find_node("PlayerBulletSpawner", true, false)
onready var enemy_bullet_spawner = get_tree().root.find_node("EnemyBulletSpawner", true, false)

signal hit

func _on_Detector_area_shape_entered(_area_id: RID, _area: Area2D, _area_shape: int, _self_shape: int) -> void:
	if detecting:
		emit_signal('hit')
		if player:
			enemy_bullet_spawner.queue_free_bullet(_area_shape)
		elif !player and !player_bullet_spawner.is_bullet_pierce(_area_shape):
			player_bullet_spawner.queue_free_bullet(_area_shape)
		if iframes > 0:
			detecting = false
			yield(get_tree().create_timer(iframes), "timeout")
			detecting = true
