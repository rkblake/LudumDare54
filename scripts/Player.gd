extends KinematicBody2D

onready var detector = $Detector

var speed = 200  # speed in pixels/sec
var velocity = Vector2.ZERO
var health = 20.0
const MAX_HEALTH = 20.0
var powerups := [0,0,0]

signal shoot_bullet(direction, speed, spin, scale)
signal player_health(health)

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
    # Make sure diagonal movement isn't faster
    velocity = velocity.normalized() * speed

func _physics_process(_delta):
#    look_at(get_global_mouse_position())
    get_input()
    velocity = move_and_slide(velocity)

func _input(event):
	if event.is_action_pressed('shoot'):
		var scale = 1.0
		if powerups[0] > 0:
			scale = 2.0 if powerups[0] > 0 else 1.0
			powerups[0] -= 1
		emit_signal('shoot_bullet', get_global_mouse_position() - global_position, 200, 0, scale)
	elif event.is_action_pressed('dodge'):
		dodge()


func _on_Detector_hit():
	health -= 1
	emit_signal('player_health', health/MAX_HEALTH)

func dodge() -> void:
	if $DodgeCooldown.is_stopped():
		$DodgeCooldown.start()
		detector.detecting = false
		speed = 350
		$Sprite.modulate.a = 0.5
		yield(get_tree().create_timer(0.5), "timeout")
		detector.detecting = true
		speed = 200
		$Sprite.modulate.a = 1.0

func powerup(effect) -> void:
	match effect:
		"BIG":
			powerups[0] += 10
		"SHOTGUN":
			powerups[1] += 10
		"DOUBLE":
			for i in len(powerups):
				powerups[i] *= 2
