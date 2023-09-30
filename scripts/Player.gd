extends KinematicBody2D

onready var detector = $Detector

var speed = 200  # speed in pixels/sec
var velocity = Vector2.ZERO
var health = 20

signal shoot_bullet(direction)

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
		emit_signal('shoot_bullet', get_global_mouse_position() - global_position)
	elif event.is_action_pressed('dodge'):
		dodge()


func _on_Detector_hit():
	health -= 1
	$CanvasLayer/Health.text = "Health %d" % health

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
