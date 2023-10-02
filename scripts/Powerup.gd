extends Area2D

const effects = ["BIG", "SHOTGUN", "DOUBLE"]
export (String, "BIG", "SHOTGUN", "DOUBLE") var effect


func _ready():
	var rand = randi() % len(effects)
	effect = effects[rand]
	$Sprite.texture = $Sprite.texture.duplicate(true)
	$Sprite.texture.region.position.x = 80 + rand * 16


func _on_Powerup_body_entered(body):
	if body.has_method('powerup'):
		body.powerup(effect)
		queue_free()
