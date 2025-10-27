extends MeshInstance3D


func _on_timer_timeout():
	# Send the player in the air to simulate a vanish/out of sight
	position.y = 100


func _on_area_3d_body_entered(body):
	print(body)
	$Timer.start()
