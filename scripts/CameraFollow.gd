extends Sprite

func _physics_process(delta):
	self.global_position.x = floor($"../..".position.x / 64) * 64
	self.global_position.y = floor($"../..".position.y / 64) * 64
