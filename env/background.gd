extends Node2D

@export var vignette : CanvasItem
@export var outside_of_area_damage : float

# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	if not get_tree().paused:
		if vignette:
			if $Area.has_overlapping_areas():
				for value: Area2D in $Area.get_overlapping_areas():
					get_multiplayer_authority() == multiplayer.get_unique_id()
					if value.has_method("is_local_player"):
						if value.is_local_player():
							vignette.visible = true
			else:
				vignette.visible = false
		for value: Area2D in $Area.get_overlapping_areas():
			if value.has_method("take_damage"):
				value.take_damage(outside_of_area_damage * delta)
