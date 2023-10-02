extends KinematicBody2D

onready var detector = $Detector

var speed = 200  # speed in pixels/sec
var velocity = Vector2.ZERO
var health = 20.0
const MAX_HEALTH = 20.0
var invuln = false
var can_play_hurt_sound = true

var xp = 0.0
const MAX_XP = 20.0

var powerups := [0,0,0]

signal shoot_bullet(direction, speed, spin, scale, pierce)
signal player_health(health)
signal gain_xp
signal clear_glitches


func get_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed('right'):
		velocity.x += 1
	if Input.is_action_pressed('left'):
		velocity.x -= 1
	if Input.is_action_pressed('down'):
		velocity.y += 1
	if Input.is_action_pressed('up'):
		velocity.y -= 1
	if Input.get_joy_axis(0, 0) > 0.5:
		velocity.x += 1
	elif Input.get_joy_axis(0, 0) < -0.5:
		velocity.x -= 1
	elif Input.get_joy_axis(0, 1) > 0.5:
		velocity.y += 1
	elif Input.get_joy_axis(0, 1) < -0.5:
		velocity.y -= 1
	# Make sure diagonal movement isn't faster
	velocity = velocity.normalized() * speed


func _physics_process(_delta):
#    look_at(get_global_mouse_position())
	get_input()
	velocity = move_and_slide(velocity)
	
	$ReadyParticles.emitting = true if $DodgeCooldown.is_stopped() else false


func _input(event):
#	var scale = 1.0
	if event.is_action_pressed('shoot'):
		shoot_bullet(get_global_mouse_position() - global_position)
	elif event.is_action_pressed('dodge'):
		dodge()
	elif event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_2 and event.axis_value > 0.5:
			shoot_bullet(Vector2.RIGHT)
		elif event.axis == JOY_AXIS_2 and event.axis_value < -0.5:
			shoot_bullet(Vector2.LEFT)
		elif event.axis == JOY_AXIS_3 and event.axis_value > 0.5:
			shoot_bullet(Vector2.DOWN)
		elif event.axis == JOY_AXIS_3 and event.axis_value < -0.5:
			shoot_bullet(Vector2.UP)


func shoot_bullet(direction: Vector2) -> void:
	var scale = 1.0
	var num_shots = 1
	var pierce = false
	if powerups[0] > 0:
		scale = 2.0
		powerups[0] -= 1
	if powerups[1] > 0:
		num_shots = 3
		powerups[1] -= 1
	if powerups[2] > 0:
		pierce = true
		powerups[2] -= 1
	for _i in num_shots:
		emit_signal('shoot_bullet', direction.rotated(randf()*0.6-0.3), 200, 0, scale, pierce)


func hit(damage = 1.0) -> void:
	if not invuln:
		health -= damage
		check_health()
		emit_signal('player_health', health/MAX_HEALTH)
		$HurtSound.play()
		invuln = true
		$AnimationPlayer.play('hit_flash')
		yield(get_tree().create_timer(0.5), "timeout")
		invuln = false
		


func damage_over_time(damage) -> void:
	health -= damage
	emit_signal('player_health', health/MAX_HEALTH)
	check_health()
	if can_play_hurt_sound:
		$HurtSound.play()
		can_play_hurt_sound = false
		yield(get_tree().create_timer(0.5), "timeout")
		can_play_hurt_sound = true


func check_health() -> void:
	if health <= 0:
		get_tree().paused = true
		yield(get_tree().create_timer(2), "timeout")
		get_tree().change_scene("res://scenes/MainMenu.tscn")


func _on_Detector_hit():
	hit()


func dodge() -> void:
	if $DodgeCooldown.is_stopped():
		$DashingParticles.emitting = true
		$DodgeCooldown.start()
		detector.detecting = false
		speed = 350
		$Sprite.modulate.a = 0.5
		yield(get_tree().create_timer(0.5), "timeout")
		detector.detecting = true
		speed = 200
		$Sprite.modulate.a = 1.0
		$DashingParticles.emitting = false


func powerup(effect, strength) -> void:
	$PowerupSound.play()
	match effect:
		"BIG":
			powerups[0] += 10 + strength * 10
		"SHOTGUN":
			powerups[1] += 10 + strength * 10
		"DOUBLE":
			for i in len(powerups):
				powerups[i] *= 2 + strength
		"PIERCE":
			powerups[2] += 10 + strength * 10


func gain_xp() -> void:
	xp += 1
	if xp >= MAX_XP:
		$OrbSound.pitch_scale = 2
		$OrbSound.play()
		emit_signal('clear_glitches')
		$LevelUpParticles.emitting = true
		$OrbSound.play()
		xp = 0
		health = MAX_HEALTH
		emit_signal('player_health', health/MAX_HEALTH)
	else:
		$OrbSound.pitch_scale = 1
		$OrbSound.play()
		
	emit_signal('gain_xp', xp/MAX_XP)
