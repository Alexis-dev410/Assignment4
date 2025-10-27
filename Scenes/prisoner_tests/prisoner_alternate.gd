extends MeshInstance3D

func _ready():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property($".", "position", position + Vector3(11,0,0), 5)
	tween.tween_property($".", "position", position + Vector3(-11,0,0), 5)

func _on_timer_timeout():
	position.y = 100


func _on_area_3d_body_entered(body):
	print(body)
	$Timer.start()
