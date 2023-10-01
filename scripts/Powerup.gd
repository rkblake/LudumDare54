extends Area2D

export (String, "BIG", "SHOTGUN", "DOUBLE") var effect

func _on_Powerup_body_entered(body):
	if body.has_method('powerup'):
		body.powerup(effect)
		queue_free()
