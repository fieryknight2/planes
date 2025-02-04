extends Area2D

@export var m_type : String

func _process(delta):
	position.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	if position.y > 1300:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Players"):
		area.pick_up_crate(m_type)
		queue_free()
