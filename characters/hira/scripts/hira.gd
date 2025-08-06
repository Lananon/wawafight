extends character_root

var dash_buffer: String = ""
var dash_buffer_timer: int
@export var dash_duration: int = 13
@export var dash_speed: int = 19
@export var back_dash_duration: int = 25
@export var back_dash_speed: Vector2i = Vector2i(-15, -6)

var dash_input_steps: int = 0
var dash_input_leniency: int = 8
var dash_input_reset: int = 0

var back_dash_input_steps: int = 0
var back_dash_input_reset: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	move_dictionary = {
		[Vector2i(0, 0), "A"]: "5A",
		[Vector2i(0, 1), "A"]: "2A",
		[Vector2i(0, 0), "B"]: "5B",
		[Vector2i(0, 1), "B"]: "2B"
	}
	
	duration_dictionary = {
		"5A": 15,
		"2A": 14,
		"5B": 23,
		"2B": 23
	}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func character_specific_code() -> void:
	#double tap dash
	if dash_input_steps == 0:
		if get_input_vector().x == side:
			dash_input_steps = 1
			dash_input_reset = dash_input_leniency
	if dash_input_steps == 1:
		if get_input_vector().x != side:
			dash_input_steps = 2
			dash_input_reset = dash_input_leniency
	if dash_input_steps == 2:
		if get_input_vector().x == side:
			dash_buffer = "forward"
			dash_buffer_timer = buffer_window
			dash_input_steps = 0
	#double tap backdash
	if back_dash_input_steps == 0:
		if get_input_vector().x == -side:
			back_dash_input_steps = 1
			back_dash_input_reset = dash_input_leniency
	if back_dash_input_steps == 1:
		if get_input_vector().x != -side:
			back_dash_input_steps = 2
			back_dash_input_reset = dash_input_leniency
	if back_dash_input_steps == 2:
		if get_input_vector().x == -side:
			dash_buffer = "back"
			dash_buffer_timer = buffer_window
			back_dash_input_steps = 0
	
	if Input.is_action_just_pressed(get_parent().dash):
		print("dash pressed")
		if get_input_vector().x != -side:
			dash_buffer = "forward"
			dash_buffer_timer = buffer_window
		if get_input_vector().x == -side:
			dash_buffer = "back"
			dash_buffer_timer = buffer_window
	
	if state == "neutral":
		if is_on_ground():
			if dash_buffer == "forward":
				set_state("dash", dash_duration)
				velocity.x = dash_speed * side
			if dash_buffer == "back":
				set_state("back_dash", back_dash_duration)
				velocity.x = back_dash_speed.x * side
				velocity.y = back_dash_speed.y
	
	dash_buffer_timer -= 1
	dash_input_reset -= 1
	back_dash_input_reset -= 1
	if dash_buffer_timer <= 0:
		dash_buffer = ""
	if dash_input_reset <= 0:
		dash_input_steps = 0
	if back_dash_input_reset <= 0:
		back_dash_input_steps = 0

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
	if state == "knockdown":
		animation_player.play("knockdown")
	if state == "dash":
		animation_player.play("dash")
	if state == "back_dash":
		animation_player.play("backdash")

func anim_update(visuals_only: bool = false, check_inputs: bool = false):
	set_anims()
	if check_inputs:
		execute_inputs()
	if visuals_only == false:
		animation_player.animate()
	if visuals_only == true:
		animation_player.animate(true)
