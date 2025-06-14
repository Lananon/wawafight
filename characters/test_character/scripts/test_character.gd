extends character_root


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	move_dictionary = {
		[Vector2i(0, 0), "A"]: "5A",
		[Vector2i(0, 1), "A"]: "5A"
	}
	
	duration_dictionary = {
		"5A": 15
	}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_anims():
	if state == "neutral":
		if is_on_ground():
			if get_input_vector().y == 1:
				animation_player.play("crouch")
			else:
				animation_player.play("idle")
		else: 
			animation_player.play("idle")
			
	if state == "attack":
		animation_player.play(current_move)
	if state == "hitstun":
		animation_player.play("hitstun")
	if state == "crouch_blockstun":
		animation_player.play("crouch_blockstun")
	if state == "stand_blockstun":
		animation_player.play("stand_blockstun")

func anim_update(visuals_only: bool = false, check_inputs: bool = false):
	set_anims()
	if check_inputs:
		execute_inputs()
	if visuals_only == false:
		animation_player.animate()
	if visuals_only == true:
		animation_player.animate(true)
