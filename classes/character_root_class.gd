extends Node2D

class_name character_root

##object references
@onready var animation_player = get_node("animation_player")
@onready var game = get_parent().get_parent()

##movement variables
#all of these are in quarter pixels per frame
@export var walk_speed: int
@export var jump_speed: int
@export var jump_height: int
var jump_direction: int
var side: int = 1
var is_cornered: bool = false
##physics variables
#use this to calculate position changes, do not use global_position itself
#meant to be used when you need position changes smaller than 1 pixel
var upscaled_position: Vector2i
const upscaling_factor: int = 4
#velocity, in quarter pixels per frame
var velocity: Vector2i
@export var gravity: int
const floor_height: int = 560
var decel: int = 1
#only used for checking for landing, dont use for actual ground checks
var has_landed: bool = false
##state machine variables
var state: String = "neutral"
var state_reset_timer: int = 0
var current_move: String
var cancel_options: Array = []
var is_hitbox_active: bool = false
var freeze_buffer: int
var freeze_timer: int
var combo: int
##input variables
const buffer_window: int = 8
var button_buffer: String
var direction_buffer: Vector2i
var buffer_timer: int
var move_dictionary = {}
var duration_dictionary = {}


##methods for things idkk
func get_input_vector() -> Vector2i:
	var vector: Vector2i = Vector2i(0, 0)
	if Input.is_action_pressed(get_parent().left):
		vector.x -= 1
	if Input.is_action_pressed(get_parent().right):
		vector.x += 1
	if Input.is_action_pressed(get_parent().up):
		vector.y -= 1
	if Input.is_action_pressed(get_parent().down):
		vector.y += 1
	return vector

func is_on_ground() -> bool:
	if upscaled_position.y >= floor_height:
		return true
	else:
		return false

func set_state(state_to_set: String, duration: int) -> void:
	state = state_to_set
	state_reset_timer = duration
	cancel_options = []

func get_opponent():
	if get_parent().name == "player1":
		return get_node("/root/game/player2").get_child(0)
	else:
		return get_node("/root/game/player1").get_child(0)

func get_hurtbox():
	return animation_player.current_step.get_node("hurtbox")

func get_hitbox():
	return animation_player.current_step.get_node("hitbox")

func on_hit(attack) -> void:
	if get_opponent().is_hitbox_active:
		z_index = 0
		get_opponent().z_index = 1
		get_opponent().cancel_options = attack.cancel_options
		get_opponent().freeze_buffer = attack.self_hitstop
		freeze_buffer = attack.hitstop
		if ["neutral", "stand_blockstun", "crouch_blockstun"].has(state):
			if attack.block_type.has(get_block_type()):
				apply_horizontal_knockback(attack.pushback)
				if get_block_type() == "LOW":
					set_state("crouch_blockstun", attack.blockstun)
				if get_block_type() == "HIGH":
					set_state("stand_blockstun", attack.blockstun)
				if get_block_type() == "AIR":
					set_state("stand_blockstun", attack.blockstun)
			else:
				succesful_hit(attack)
		else:
			succesful_hit(attack)
		get_opponent().is_hitbox_active = false

func buffer(button: String, direction: Vector2i) -> void:
	button_buffer = button
	direction_buffer = direction
	buffer_timer = buffer_window

func get_block_type():
	if get_input_vector().x * side == -1:
		if is_on_ground():
			if get_input_vector().y == 1:
				return "LOW"
			else:
				return "HIGH"
		else:
			return "AIR"
	else:
		return "nothing"

func apply_horizontal_knockback(kb):
	if not is_cornered: 
		velocity.x = kb * get_opponent().side
	if is_cornered and get_opponent().is_on_ground():
		get_opponent().velocity.x = -kb * get_opponent().side

func succesful_hit(attack):
	if is_on_ground():
		combo += 1
		set_state("hitstun", attack.hitstun)
		apply_horizontal_knockback(attack.knockback.x)
		velocity.y = attack.knockback.y
	else:
		combo += 1
		set_state("hitstun", attack.hitstun)
		apply_horizontal_knockback(attack.air_knockback.x)
		velocity.y = attack.air_knockback.y


func execute_inputs():
	var closest_valid_input: Array
	if button_buffer != "":
		if move_dictionary.has([direction_buffer, button_buffer]):
			closest_valid_input = [direction_buffer, button_buffer]
		elif move_dictionary.has([Vector2i(0, direction_buffer.y), button_buffer]):
			closest_valid_input = [Vector2i(0, direction_buffer.y), button_buffer]
		else:
			closest_valid_input = [Vector2i(0, 0), button_buffer]
			
		
		if state == "neutral" or cancel_options.has(move_dictionary[closest_valid_input]):
			button_buffer = ""
			direction_buffer = Vector2i(0, 0)
			current_move = move_dictionary[closest_valid_input]
			set_state("attack", duration_dictionary[move_dictionary[closest_valid_input]])
			animation_player.force_anim_reset()

func process_inputs() -> void:
	
	
	if Input.is_action_just_pressed(get_parent().a):
		buffer("A", get_input_vector())

func check_for_hit() -> void:
	if get_hurtbox().get_overlapping_areas().has(get_opponent().get_hitbox()):
		on_hit(get_opponent().animation_player.current_step)

func calculate_physics() -> void:
	velocity.y += gravity
	
	if is_on_ground():
		if velocity.x > 0:
			velocity.x = max(0, velocity.x - decel)
		if velocity.x < 0:
			velocity.x = min(0, velocity.x + decel)
			
	upscaled_position += velocity
	
	if upscaled_position.y >= floor_height:
		upscaled_position.y = floor_height

func movement() -> void:
	if is_on_ground() and state == "neutral":
		if get_input_vector().y != 1:
			if get_input_vector().x != 0:
				velocity.x = get_input_vector().x * walk_speed
		
		#jumping
		if get_input_vector().y == -1:
			set_state("jump_startup", 4)
			
	
	if get_input_vector().x == 1:
		jump_direction = 1
	if get_input_vector().x == -1:
		jump_direction = -1
	if get_input_vector() == Vector2i(0, -1):
		jump_direction = 0
	
	if state == "jump_startup" and state_reset_timer == 1:
		velocity.y = -jump_height
		velocity.x = jump_speed * jump_direction

func end_of_frame() -> void:
	if side == 1:
		if upscaled_position.x <= 16:
			upscaled_position.x = 16
			is_cornered = true
		if upscaled_position.x >= game.stage_size.x * 4 -24:
			upscaled_position.x = game.stage_size.x * 4 -24
		if not upscaled_position.x <= 16 and not upscaled_position.x >= game.stage_size.x * 4 -24:
			is_cornered = false
		
	if side == -1:
		if upscaled_position.x <= 24:
			upscaled_position.x = 24
		if upscaled_position.x >= game.stage_size.x * 4 -16:
			upscaled_position.x = game.stage_size.x * 4 -16
			is_cornered = true
		if not upscaled_position.x <= 24 and not upscaled_position.x >= game.stage_size.x * 4 -16:
			is_cornered = false
	
	buffer_timer -= 1
	if buffer_timer <= 0:
		button_buffer = ""
		direction_buffer = Vector2i(0, 0)
	
	global_position = Vector2i(upscaled_position / upscaling_factor)
	
	if is_on_ground() and state == "neutral":
		if upscaled_position.x >= get_opponent().upscaled_position.x:
			side = -1
		if upscaled_position.x < get_opponent().upscaled_position.x:
			side = 1
	
	scale.x = side
	
	if has_landed == false and is_on_ground():
		if state == "hitstun":
			set_state("knockdown", 30)
		else:
			set_state("neutral", 0)
		has_landed = true
		
	
	state_reset_timer -= 1
	
	if state_reset_timer == 0 and state == "hitstun" and not is_on_ground():
		state_reset_timer = 1
	
	if state_reset_timer == 0:
		state = "neutral"
		animation_player.current_frame = 1
		
	if not is_on_ground():
		has_landed = false
	
	print(has_landed)
	if state == "neutral":
		
		combo = 0
	
	if not state == "attack":
		cancel_options = []

func freeze_update():
	freeze_timer -= 1
	
	if freeze_buffer != 0:
		freeze_timer = freeze_buffer
	
	
	freeze_buffer = 0
