extends Node2D

class_name character_root

##object references
@onready var animation_player = get_node("animation_player")

##movement variables
#all of these are in quarter pixels per frame
@export var walk_speed: int
@export var jump_speed: int
@export var jump_height: int
var jump_direction: int
var side: int = 1
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
##state machine variables
var state: String = "neutral"
var state_reset_timer: int = 0
var current_move: String
var cancel_options: Array = []
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

func get_opponent():
	if get_parent().name == "player1":
		return get_node("/root/game/player2").get_child(0)
	else:
		return get_node("/root/game/player1").get_child(0)

func get_hurtbox():
	return animation_player.current_step.get_node("hurtbox")

func get_hitbox():
	return animation_player.current_step.get_node("hitbox")

func on_hit() -> void:
	print("woof!")

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






func execute_inputs():
	var closest_valid_input: Array
	if button_buffer != "":
		if move_dictionary.has([direction_buffer, button_buffer]):
			closest_valid_input = [direction_buffer, button_buffer]
		elif move_dictionary.has([Vector2i(0, direction_buffer.y), button_buffer]):
			closest_valid_input = [Vector2i(0, direction_buffer.y), button_buffer]
		else:
			closest_valid_input = [Vector2i(0, 0), button_buffer]
			
		if state == "neutral" or cancel_options.has(closest_valid_input):
			current_move = move_dictionary[closest_valid_input]
			set_state("attack", duration_dictionary[move_dictionary[closest_valid_input]])

func process_inputs() -> void:
	buffer_timer -= 1
	if buffer_timer <= 0:
		button_buffer = ""
		direction_buffer = Vector2i(0, 0)
	
	if Input.is_action_just_pressed(get_parent().a):
		buffer("A", get_input_vector())

func check_for_hit() -> void:
	if get_hurtbox().get_overlapping_areas().has(get_opponent().get_hitbox()):
		on_hit()

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
	global_position = Vector2i(upscaled_position / upscaling_factor)
	
	if is_on_ground() and state == "neutral":
		if upscaled_position.x >= get_opponent().upscaled_position.x:
			side = -1
		if upscaled_position.x < get_opponent().upscaled_position.x:
			side = 1
	
	scale.x = side
	
	state_reset_timer -= 1
	
	if state_reset_timer <= 0:
		state = "neutral"
		
	print(get_block_type())
