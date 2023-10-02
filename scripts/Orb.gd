extends Area2D

var creation_time = OS.get_ticks_msec()

func _process(_delta):
	$Sprite.position.y = int(sin((OS.get_ticks_msec() - creation_time)/100)*6)


func _on_Orb_body_entered(body):
	if body.has_method('gain_xp'):
		body.gain_xp()
		queue_free()
