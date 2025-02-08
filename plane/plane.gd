extends Area2D

@export_category("Controls")
@export var speed := 250
@export var rotate_speed : float = 4
@export var follow_mouse_speed : float = 20

@export var outof_bounds : Vector4i

@export_group("Mouse")
@export var mouse_dist : float
@export var mouse_dist_threshold : float

# Gameplay
@export_category("Health")
@export var max_health := 50.0
@export var regen_speed := 10.0

@export var health = max_health

@export_category("Weapons")

@export var firing_speed : float = 1
@export var bullet_node: NodePath
var wait_time = 0
var timer = null

@export var power_length: float

@export var bullet_type: String = "default"


@export_group("Weapons")

@export var default_weapon : PackedScene
@export var multishot_weapon : PackedScene
@export var powershot_weapon : PackedScene

@export_category("Miscellaneous")

@export var death_messages: Array[String]
@export var kill_messages: Array[String]

@export var visual_name: String

@export var player := 1 : 
	set(id): 
		player = id
		$PlayerInput.set_multiplayer_authority(id)

var animating_color_time = 0
var animating_color = false

var last_source

@export var animation_length := 0.4
@export var color: Color

func _ready():
	$Health.max_value = max_health
	$Health.value = health
	
	if is_local_player():
		$Camera2D.make_current()
	
	$Sprite/Sprite.modulate = color
	
	$Label.text = visual_name
	if visual_name == "":
		$Label.text = "<unnamed>"

func is_local_player() -> bool:
	return player == multiplayer.get_unique_id()

func get_id():
	return player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	wait_time += delta
	if not $PlayerInput.use_mouse:
		var rot_dir = clamp($PlayerInput.rotation_dir, -1, 1)
		$Sprite.rotation += rot_dir * rotate_speed * delta
	else:
		var effect = clamp(($PlayerInput.target_pos - position).length_squared() / pow(mouse_dist_threshold, 2), 0, 1)
		var prev_rotation = $Sprite.rotation
		$Sprite.rotation = global_position.angle_to_point($PlayerInput.target_pos)
		$Sprite.rotation = lerp_angle(prev_rotation, get_angle_to($PlayerInput.target_pos), delta * follow_mouse_speed * effect)
	
	var rot = $Sprite.rotation
	var uscale = abs(cos(rot * 2)) * 0.295
	$Sprite/Sprite.scale.x = 0.005 + uscale
	
	var cspeed = clamp((($PlayerInput.target_pos - position)).length_squared() / pow(mouse_dist, 2), 0, 1) * speed if $PlayerInput.use_mouse else speed
	var direction_dir = Vector2.from_angle($Sprite.rotation)
	var direction_velocity = direction_dir * cspeed * delta
	position += direction_velocity
	
	if wait_time > firing_speed and $PlayerInput.firing:
		if multiplayer.is_server():
			fire()
			wait_time = 0
	
	health += regen_speed * delta
	health = clamp(health, 0, max_health)
	$Health.value = health
	$Health.visible = true if health < max_health else false
	
	if animating_color:
		animating_color_time += delta
		if animating_color_time < 0.2:
			$Sprite/Sprite.modulate = lerp(color, Color.RED, (animating_color_time/(animation_length/2)))
		else:
			$Sprite/Sprite.modulate = lerp(color, Color.RED, ((animating_color_time-0.2)/(animation_length/2)))
		
		if animating_color_time > animation_length:
			$Sprite/Sprite.modulate = color
			animating_color = false
			animating_color_time = 0
	
	if health <= 0:
		die()
		return
	
	var pos = position
	if pos.x < outof_bounds.x or pos.x > outof_bounds.w \
		or pos.y < outof_bounds.y or pos.y > outof_bounds.z:
			die()
			return

func die():
	if !is_multiplayer_authority():
		return
		
	var message = ""
	if last_source.begins_with("player"):
		message = kill_messages.pick_random() % [Network.get_user_name(last_source.substr(6, -1)), Network.get_user_name(str(name))]
	else:
		message = death_messages.pick_random() % (Network.get_user_name(str(name)))
	
	get_tree().current_scene.kill_player.rpc_id(1, str(name), message)
	
	# position = Vector2(0, 0)
	# health = max_health
	# $Health.value = health
	# swap_bullet_type("default")
	
	# $Trail.clear_points()
	# $Trail.curve.clear_points()
	# $Trail2.clear_points()
	# $Trail2.curve.clear_points()

func take_damage(damage, source="natural"):
	health -= damage
	animating_color = true
	
	last_source = source

var bid = 0
func fire():
	var weapon = null
	
	if bullet_type == "multishot":
		weapon = multishot_weapon
	elif bullet_type == "powershot":
		weapon = powershot_weapon
	else:
		weapon = default_weapon
	
	spawn_bullet(weapon, {})
	
	if bullet_type == "multishot":
		spawn_bullet(weapon, {"rotation": 0.09})
		spawn_bullet(weapon, {"rotation": -0.09})

func spawn_bullet(type, settings):
	var bullet = type.instantiate()
	bullet.rotation = $Sprite.rotation + (settings["rotation"] if settings.has("rotation") else 0)
	bullet.position = $Sprite/FireLocation.global_position
	bullet.from_player = player
	bullet.name = str(player) + "_" + str(bid) + "_" + str(randi_range(0, 10000))
	bid += 1
	get_node(bullet_node).add_child(bullet, true)

func pick_up_crate(value):
	if value == "health":
		health += max_health / 2
		health = clamp(health, 0, max_health)
	if value == "multishot" or value == "powershot":
		swap_bullet_type(value)

func swap_bullet_type(type="default"):
	if timer:
		timer.disconnect("timeout", swap_bullet_type)
		timer = null
	
	if type == "multishot" or type == "powershot":
		timer = get_tree().create_timer(power_length)
		timer.connect("timeout", swap_bullet_type)
	
	if type == "default":
		firing_speed = 0.2
	elif type == "powershot":
		firing_speed = 0.4
	elif type == "multishot":
		firing_speed = 0.15
	else:
		firing_speed = 0.2
	
	bullet_type = type
