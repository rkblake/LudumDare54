extends Area2D

func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_method('damage_over_time'):
			body.damage_over_time(delta * 1.5)
