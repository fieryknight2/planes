extends Node2D

@export var vignette : CanvasItem
@export var outside_of_area_damage : float

# Called when the node enters the scene tree for the first time.
func _physics_process(delta: float) -> void:
	if not get_tree().paused:
		if vignette:
			var player_in_range = false
			if $Area.has_overlapping_areas():
				for value: Area2D in $Area.get_overlapping_areas():
					if value.is_in_group("Players"):
						if value.is_local_player():
							player_in_range = true
							break
			vignette.visible = player_in_range
			
		for value: Area2D in $Area.get_overlapping_areas():
			if value.is_in_group("Players"):
				value.take_damage(outside_of_area_damage * delta)
