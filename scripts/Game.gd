extends Node2D

onready var player_bullet_spawner = $PlayerBulletSpawner
onready var enemy_bullet_spawner = $EnemyBulletSpawner
onready var top_left = $TopLeft
onready var bottom_right = $BottomRight
onready var player = $Player

export (Array, PackedScene) var enemies

var boundary_rect: Rect2

func _ready():
	randomize()
	boundary_rect = Rect2(
		top_left.position, bottom_right.position - top_left.position
	)
	player_bullet_spawner.set_bounding_box(boundary_rect)
	enemy_bullet_spawner.set_bounding_box(boundary_rect)

func _on_Player_shoot_bullet(direction: Vector2):
	player_bullet_spawner.spawn_bullet(direction)


func _on_enemy_shoot_bullet(direction: Vector2, position: Vector2) -> void:
	enemy_bullet_spawner.spawn_bullet(direction, position)


func _on_SpawnTimer_timeout():
	var enemy = enemies[randi() % len(enemies)].instance()
	# TODO: find empty tile
	enemy.position = Vector2(100,100)
	enemy.player = player
	enemy.connect("shoot_bullet", self, "_on_enemy_shoot_bullet")
	add_child(enemy)
