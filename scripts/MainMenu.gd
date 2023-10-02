extends Control

onready var high_score_label = $MarginContainer/CenterContainer/HBoxContainer/VBoxContainer/HighScoreLabel
onready var options = $Options

func _ready():
	get_tree().paused = false
	Globals.score = 0
	high_score_label.text = "High Score: %03d" % Globals.high_score

func _on_StartButton_pressed():
	get_tree().change_scene("res://scenes/Game.tscn")


func _on_OptionsButton_pressed():
	options.show()


func _on_QuitButton_pressed():
	get_tree().quit(0)


func _on_CrtEffect_toggled(is_crt_enabled):
	Globals.options['crt_enabled'] = is_crt_enabled


func _on_Mute_toggled(is_mute):
	AudioServer.set_bus_mute(0, is_mute)


func _on_Back_pressed():
	options.hide()
