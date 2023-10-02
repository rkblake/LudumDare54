extends Area2D

var strength = 0
const effects = [" BIG", "SHOTGUN", "DOUBLE"]
export (String, "BIG", "SHOTGUN", "DOUBLE") var effect


func _ready():
	var rand = randi() % len(effects)
	strength = randi() % 2
	effect = effects[rand]
	$Sprite.texture = $Sprite.texture.duplicate(true)
	$Sprite.texture.region.position.x = 80 + rand * 16
	$Sprite.texture.region.position.y = 144 if strength == 1 else 160


func _on_Powerup_body_entered(body):
	if body.has_method('powerup'):
		body.powerup(effect, strength)
		queue_free()
