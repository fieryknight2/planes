extends MultiplayerSynchronizer

@export var rotation_dir : float = 0
@export var target_pos : Vector2
@export var use_mouse : bool = true
@export var firing : bool = false

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		#print("Disabling input for " + str(get_multiplayer_authority()) + 
		#		" because real id is " + str(multiplayer.get_unique_id()))
		set_process(false)
		# set_physics_process(false)
	else:
		set_process(true)

@rpc("call_local")
func set_use_mouse(value):
	use_mouse = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	rotation_dir = Input.get_axis("rotate_counterclockwise", "rotate_clockwise")
	if rotation_dir != 0:
		set_use_mouse(false)
	else:
		if use_mouse:
			target_pos = get_parent().get_global_mouse_position()
	
	if Input.is_action_pressed("enable_mouse"):
		set_use_mouse(true)
	
	if Input.is_action_pressed("fire_a"):
		firing = true
	else:
		firing = false
