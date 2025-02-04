extends Area2D

@export var speed := 250
@export var rotate_speed : float = 4
@export var follow_mouse_speed : float = 20

@export var rotating_tex : Texture2D
@export var sideways_tex : Texture2D
@export var upwards_tex : Texture2D

# Gameplay
@export var max_health := 50.0
@export var regen_speed := 10.0

@export var health = max_health

@export var outof_bounds : Vector4i

@export var mouse_dist : float
@export var mouse_dist_threshold : float

@export var firing_speed : float = 1
@export var weapon1 : PackedScene
var wait_time = 0

@export var bullet_node: NodePath

@export var player := 1 : 
	set(id): 
		player = id
		$PlayerInput.set_multiplayer_authority(id)

func _ready():
	$Health.max_value = max_health
	$Health.value = health
	
	if is_local_player():
		$Camera2D.make_current()
	else:
		$Sprite/Sprite.modulate = Color.CHARTREUSE

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
	
	var direction_dir = Vector2.from_angle($Sprite.rotation)
	
	while $Sprite.rotation_degrees > 360:
		$Sprite.rotation_degrees -= 360
	while $Sprite.rotation_degrees < 0:
		$Sprite.rotation_degrees += 360
	if $Sprite.rotation_degrees >= 90 and $Sprite.rotation_degrees <= 270:
		pass # $Sprite/Sprite.flip_v = true
	else:
		pass # $Sprite/Sprite.flip_v = false
	
	var cspeed = clamp((($PlayerInput.target_pos - position)).length_squared() / pow(mouse_dist, 2), 0, 1) * speed if $PlayerInput.use_mouse else speed
	var direction_velocity = direction_dir * cspeed * delta
	position += direction_velocity
	
	if wait_time > firing_speed and $PlayerInput.firing:
		fire()
		wait_time = 0
	
	health += regen_speed * delta
	health = clamp(health, 0, max_health)
	$Health.value = health
	$Health.visible = true if health < max_health else false
	
	if health <= 0:
		die()
		return
	
	var pos = position
	if pos.x < outof_bounds.x or pos.x > outof_bounds.w \
		or pos.y < outof_bounds.y or pos.y > outof_bounds.z:
			die()
			return

func die():
	position = Vector2(0, 0)
	health = max_health
	$Health.value = health

func take_damage(damage):
	health -= damage
	$AnimationPlayer.play("damage")

var bid = 0
func fire():
	var bullet = weapon1.instantiate()
	bullet.rotation = $Sprite.rotation
	bullet.position = $Sprite/FireLocation.global_position
	bullet.from_player = player
	bullet.name = str(player) + "_" + str(bid)
	bid += 1
	get_node(bullet_node).add_child(bullet, true)

func pick_up_crate(value):
	if value == "health":
		health += max_health / 2
		health = clamp(health, 0, max_health)
