extends Node

var score = 0
var high_score = 0

var options = {
	"crt_enabled": true
}

func add_score(points = 1) -> void:
	score += points
	if score > high_score:
		high_score = score
