extends Enemy

var bullet_rotation := Vector2.UP

func shoot() -> void:
	emit_signal('shoot_bullet', bullet_rotation, global_position)
	emit_signal('shoot_bullet', -bullet_rotation, global_position)
	bullet_rotation = bullet_rotation.rotated(PI/16)
