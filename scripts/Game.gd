extends Node2D

onready var player_bullet_spawner = $PlayerBulletSpawner
onready var enemy_bullet_spawner = $EnemyBulletSpawner
onready var top_left = $TopLeft
onready var bottom_right = $BottomRight
onready var player = $Player
onready var bar = $HUD/Bar
onready var bar_shadow = $HUD/BarShadow
onready var xp_bar = $HUD/XpBar
onready var xp_bar_shadow = $HUD/XpBarShadow
onready var tile_map = $TileMap

export (Array, PackedScene) var enemies
export (Array, PackedScene) var powerups

const orb_scene = preload("res://scenes/Orb.tscn")
const glitch_scene = preload("res://scenes/GlitchEffect.tscn")

var boundary_rect: Rect2

var wave = 1
const E = 2.71828

func _ready():
	randomize()
	update_bounding_rects()

func _process(delta):
	if $EnemyGroup.get_child_count() == 0:
		$SpawnTimer.start()
		spawn_wave()

func _on_Player_shoot_bullet(direction: Vector2, speed, spin, scale):
	player_bullet_spawner.spawn_bullet(direction, Vector2.ZERO, speed, spin, scale)


func _on_enemy_shoot_bullet(direction: Vector2, position: Vector2) -> void:
	enemy_bullet_spawner.spawn_bullet(direction, position, 150, 3)

func update_bounding_rects():
	boundary_rect = Rect2(
		top_left.position, bottom_right.position - top_left.position
	)
	player_bullet_spawner.set_bounding_box(boundary_rect)
	enemy_bullet_spawner.set_bounding_box(boundary_rect)

func map_to_global(tile: Vector2) -> Vector2: return tile_map.to_global(tile_map.map_to_world(tile))

func _on_SpawnTimer_timeout():
	spawn_wave()


func spawn_wave() -> void:
	var num_enemies = min(12, floor(pow(2, wave/E)))
	wave += 1
	var possible_tiles = tile_map.get_used_cells_by_id(0)
	var tile
	print('spawning %d enemies' % num_enemies)
	for i in num_enemies:
		var enemy = enemies[randi() % len(enemies)].instance()
		
		 # 0 should be ground tiles
		tile = possible_tiles[randi() % len(possible_tiles)]
		while(player.global_position.distance_squared_to(map_to_global(tile)) < 200):
			tile = possible_tiles[randi() % len(possible_tiles)]

		enemy.position = map_to_global(tile)
		enemy.player = player
		enemy.connect("shoot_bullet", self, "_on_enemy_shoot_bullet")
		enemy.connect("spawn_orb", self, "_on_spawn_orb")
		$EnemyGroup.add_child(enemy)
	
	# Spawn powerup
	var powerup = powerups[randi() % len(powerups)].instance()
	
#	possible_tiles = tile_map.get_used_cells_by_id(0) # 0 should be ground tiles
	tile = possible_tiles[randi() % len(possible_tiles)]
	while(player.global_position.distance_squared_to(map_to_global(tile)) < 200):
		tile = possible_tiles[randi() % len(possible_tiles)]

	powerup.position = map_to_global(tile)
#	powerup.player = player
#	enemy.connect("shoot_bullet", self, "_on_enemy_shoot_bullet")
	$PowerupGroup.add_child(powerup)


func _on_GlitchTimer_timeout():
	var glitch = glitch_scene.instance()
	glitch.position = Vector2((randi() % int(top_left.position.x - bottom_right.position.x))+top_left.position.x, (randi() % int(top_left.position.y - bottom_right.position.y))+top_left.position.y)
	$GlitchGroup.add_child(glitch)


func _on_player_health(health: float) -> void:
	bar.material.set_shader_param("amount", health)
	bar_shadow.material.set_shader_param("amount", health)
	$HUD/HealthNumber.text = "%02d/%02d" % [health*20, 20]


func _on_gain_xp(xp: float) -> void:
	xp_bar.material.set_shader_param("amount", xp)
	xp_bar_shadow.material.set_shader_param("amount", xp)
	$HUD/XpNumber.text = "%02d/%02d" % [xp*20, 20]


func _on_spawn_orb(position: Vector2) -> void:
	var orb = orb_scene.instance()
	orb.position = position
	yield(get_tree(), "idle_frame")
	$PowerupGroup.add_child(orb)


func _on_Player_clear_glitches() -> void:
	for child in $GlitchGroup.get_children():
		child.queue_free()
