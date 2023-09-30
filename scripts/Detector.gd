class_name Detector
extends Area2D

var detecting := true
export (float) var iframes = 0.1

signal hit

func _on_Detector_area_shape_entered(_area_id: RID, _area: Area2D, _area_shape: int, _self_shape: int) -> void:
	if detecting:
		emit_signal('hit')
		if iframes > 0:
			detecting = false
			yield(get_tree().create_timer(iframes), "timeout")
			detecting = true
