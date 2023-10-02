extends CanvasLayer

onready var crosshair = $Crosshair
var crosshair_offset: Vector2
onready var score = $Score
onready var high_score = $HighScore

func _ready():
	offset = Vector2(-crosshair.texture.get_width(), -crosshair.texture.get_width())
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event):
	if event is InputEventMouseMotion:
		crosshair.rect_position = event.position + crosshair_offset

func _process(_delta):
	score.text = "Score: %d" % Globals.score
	high_score.text = "High Score: %d" % Globals.high_score


const BOTTOM_RIGHT_OFFSET = Vector2(502, 155)
func _on_MarginContainer_resized():
	$MarginContainer/XpGroup/XpBar.rect_position = get_viewport().size - BOTTOM_RIGHT_OFFSET
	$MarginContainer/XpGroup/XpBarShadow.rect_position = get_viewport().size - BOTTOM_RIGHT_OFFSET + Vector2(6,6)
	$MarginContainer/XpGroup/OrbIcon.rect_position = get_viewport().size - BOTTOM_RIGHT_OFFSET - Vector2(40,0)
	$MarginContainer/XpGroup/XpNumber.rect_position = get_viewport().size - BOTTOM_RIGHT_OFFSET + Vector2(145,7)
	
