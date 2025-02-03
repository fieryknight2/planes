extends Area2D

@export var speed := 250
@export var rotate_speed := 6

@export var rotating_tex : Texture2D
@export var sideways_tex : Texture2D
@export var upwards_tex : Texture2D

# Gameplay
@export var max_health := 50.0
@export var regen_speed := 10.0

@export var health = max_health

@export var outof_bounds : Vector4i

@export var player := 1 : 
	set(id): 
		player = id
		$PlayerInput.set_multiplayer_authority(id)

func _ready():
	$Health.max_value = max_health
	$Health.value = health
	
	if is_local_player():
		$Camera2D.make_current()

func is_local_player() -> bool:
	return player == multiplayer.get_unique_id()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rot_dir = clamp($PlayerInput.rotation_dir, -1, 1)
	$Sprite.rotation += rot_dir * rotate_speed * delta
	var direction_dir = Vector2.from_angle($Sprite.rotation)
	
	while $Sprite.rotation_degrees > 360:
		$Sprite.rotation_degrees -= 360
	while $Sprite.rotation_degrees < 0:
		$Sprite.rotation_degrees += 360
	if $Sprite.rotation_degrees >= 90 and $Sprite.rotation_degrees <= 270:
		$Sprite/Sprite.flip_v = true
	else:
		$Sprite/Sprite.flip_v = false
	
	var direction_velocity = direction_dir * speed * delta
	position += direction_velocity
	
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

func take_damage(damage):
	health -= damage
	$AnimationPlayer.play("damage")
	
