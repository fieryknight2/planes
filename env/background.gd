extends Node2D

@export var vignette : CanvasItem
@export var outside_of_area_damage : float

@export_category("Clouds")
@export var cloud_scene : PackedScene
@export var cloud_count : int
@export var cloud_spawn_speed: float = 5
@export var preprocess_time: float = 200
var cloud_spawn_time = 0

@export_subgroup("Cloud Stats")
@export var max_cloud_speed: int
@export var min_cloud_speed: int
@export var cloud_x_spawn: int = 2400
@export var cloud_y_spawn_dist: int = 800

func _ready():
	if not is_multiplayer_authority():
		return
	
	for i in range(preprocess_time / cloud_spawn_speed):
		var new_cloud = cloud_scene.instantiate()
		new_cloud.position = Vector2(cloud_x_spawn, 
				randi_range(-cloud_y_spawn_dist, cloud_y_spawn_dist))
		new_cloud.cloud = randi_range(0, cloud_count-1)
		new_cloud.speed = randi_range(min_cloud_speed, max_cloud_speed)
		$Clouds.add_child(new_cloud, true)
		new_cloud._process(i * cloud_spawn_speed)
	cloud_spawn_time = fmod(preprocess_time, cloud_spawn_speed)

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
			# print(player_in_range)
			vignette.visible = player_in_range
			
		for value: Area2D in $Area.get_overlapping_areas():
			if value.is_in_group("Players"):
				value.take_damage(outside_of_area_damage * delta)

func _process(delta):
	if not is_multiplayer_authority():
		return
	
	cloud_spawn_time += delta
	if cloud_spawn_time > cloud_spawn_speed:
		cloud_spawn_time = 0
		spawn_cloud()

func spawn_cloud():
	if not is_multiplayer_authority():
		return
	
	var new_cloud = cloud_scene.instantiate()
	new_cloud.position = Vector2(cloud_x_spawn, 
			randi_range(-cloud_y_spawn_dist, cloud_y_spawn_dist))
	new_cloud.cloud = randi_range(0, cloud_count-1)
	new_cloud.speed = randi_range(min_cloud_speed, max_cloud_speed)
	$Clouds.add_child(new_cloud, true)
