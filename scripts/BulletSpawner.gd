class_name BulletHellSpawner
extends Node2D

export (Array, Texture) var frames
export (float) var image_change_offset = 0.2
export (float) var max_lifetime = 10.0
export (NodePath) var spawner_path; onready var spawner = get_node_or_null(spawner_path) as KinematicBody2D
export (int) var layer

onready var origin := get_node("Origin") as Position2D
onready var shared_area := get_node("SharedArea") as Area2D


onready var max_images = frames.size()

var bullets : Array = []
var bounding_box : Rect2

# ================================ Lifecycle ================================ #

func _exit_tree() -> void:
	for bullet in bullets:
		Physics2DServer.free_rid((bullet as Bullet).shape_id)
	bullets.clear()

func _physics_process(delta: float) -> void:
	
	var used_transform = Transform2D()
	var bullets_queued_for_destruction = []
	
	for i in range(0, bullets.size()):
		
		var bullet = bullets[i] as Bullet
		
		if (
			!bounding_box.has_point(bullet.current_position) or
			bullet.lifetime >= max_lifetime
		):
			bullets_queued_for_destruction.append(bullet)
			continue

		var offset : Vector2 = (
			bullet.movement_vector.normalized() * bullet.speed * delta
		)
		
		# Move the bullet and the collision
		bullet.current_position += offset
		used_transform.origin = bullet.current_position
		Physics2DServer.area_set_shape_transform(
			shared_area.get_rid(), i, used_transform
		)
		
		bullet.animation_lifetime += delta
		bullet.lifetime += delta
	
	for bullet in bullets_queued_for_destruction:
		Physics2DServer.free_rid(bullet.shape_id)
		bullets.erase(bullet)
	
	update()

func _draw() -> void:
	var offset = frames[0].get_size() / 2.0
	for i in range(0, bullets.size()):
		var bullet = bullets[i]
		if bullet.animation_lifetime >= image_change_offset:
			bullet.image_offset += 1
			bullet.animation_lifetime = 0.0
			if bullet.image_offset >= max_images:
				bullet.image_offset = 0
		draw_set_transform(bullet.current_position - offset, bullet.movement_vector.angle() + PI/2 + bullet.spin, Vector2(4,4)*bullet.scale)
		draw_texture(
			frames[bullet.image_offset], 
			Vector2(-8,-8)
		)
		bullet.spin += PI * bullet.angular_velocity * get_process_delta_time()

# ================================= Public ================================== #

# Bullets outside these bounds will be deleted
func set_bounding_box(box: Rect2) -> void:
	bounding_box = box
	Physics2DServer.area_set_collision_layer(shared_area.get_rid(), layer)

# Register a new bullet in the array with the optimization logic
func spawn_bullet(i_movement: Vector2, pos: Vector2 = Vector2.ZERO, speed := 200, angular_velocity := 0, scale := 1.0) -> void:
	
	var bullet : Bullet = Bullet.new()
	bullet.movement_vector = i_movement
	bullet.speed = speed
	bullet.angular_velocity = angular_velocity
	bullet.scale = scale
#	bullet.current_position  = origin.position
	if pos == Vector2.ZERO:
		bullet.current_position = spawner.position
	else:
		bullet.current_position = pos
	
	_configure_collision_for_bullet(bullet, scale)
	
	bullets.append(bullet)
	
# Adds the collision data to the bullet
func _configure_collision_for_bullet(bullet: Bullet, scale: float) -> void:
	
	# Define the shape's position
	var used_transform := Transform2D(0, position)
	used_transform.origin = bullet.current_position
	  
	# Create the shape
	var _circle_shape = Physics2DServer.circle_shape_create()
	Physics2DServer.shape_set_data(_circle_shape, 8 * scale)
	
	# Add the shape to the shared area
	Physics2DServer.area_add_shape(
		shared_area.get_rid(), _circle_shape, used_transform
	)
	
	# Register the generated id to the bullet
	bullet.shape_id = _circle_shape

func queue_free_bullet(area_idx: int) -> void:
#	var shape = Physics2DServer.area_get_shape(shared_area.get_rid(), area_idx)
	var bullet = bullets[area_idx]
	Physics2DServer.free_rid(bullet.shape_id)
	bullets.erase(bullet)
