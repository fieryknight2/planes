extends MultiplayerSynchronizer

@export var rotation_dir : float = 0

func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		print("Disabling input for " + str(get_multiplayer_authority()) + 
				" because real id is " + str(multiplayer.get_unique_id()))
		set_process(false)
		# set_physics_process(false)
	else:
		set_process(true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	rotation_dir = Input.get_axis("ui_left", "ui_right")
