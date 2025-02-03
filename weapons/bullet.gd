extends Area2D

@export var bullet_speed: float
@export var bullet_damage: int
@export var from_player: int
@export var bullet_existence_time: float

var remaining_time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = Vector2.from_angle(rotation)
	position += direction * delta * bullet_speed
	
	remaining_time += delta
	if remaining_time >= bullet_existence_time:
		queue_free()
		return
	
	for area in get_overlapping_areas():
		if area.is_in_group("Players"):
			if area.get_id() != from_player:
				area.take_damage(bullet_damage)
				queue_free()
