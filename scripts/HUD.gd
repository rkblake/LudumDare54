extends CanvasLayer

onready var crosshair = $Crosshair
var crosshair_offset: Vector2

func _ready():
	offset = Vector2(-crosshair.texture.get_width()/2.0, -crosshair.texture.get_width()/2.0)

func _input(event):
	if event is InputEventMouseMotion:
		crosshair.rect_position = event.position + crosshair_offset
