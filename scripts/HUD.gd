extends CanvasLayer

onready var crosshair = $Crosshair
var crosshair_offset: Vector2
onready var score = $Score
onready var high_score = $HighScore

func _ready():
	offset = Vector2(-crosshair.texture.get_width()/2.0, -crosshair.texture.get_width()/2.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event):
	if event is InputEventMouseMotion:
		crosshair.rect_position = event.position + crosshair_offset

func _process(_delta):
	score.text = "Score: %d" % Globals.score
	high_score.text = "High Score: %d" % Globals.high_score
