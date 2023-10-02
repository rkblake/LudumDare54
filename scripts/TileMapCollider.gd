extends Area2D


func _on_MapCollider_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	print(area)


func _on_MapCollider_body_entered(body):
	print(body)
