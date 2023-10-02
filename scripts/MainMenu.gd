extends Control

onready var high_score_label = $MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/HighScoreLabel

func _ready():
	get_tree().paused = false
	Globals.score = 0
	high_score_label.text = "High Score: %03d" % Globals.high_score

func _on_StartButton_pressed():
	get_tree().change_scene("res://scenes/Game.tscn")


func _on_OptionsButton_pressed():
	pass # Replace with function body.


func _on_QuitButton_pressed():
	get_tree().quit(0)
