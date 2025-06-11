extends Node2D

#movement variables
	#all of these are in quarter pixels per frame
@export var walk_speed: int
@export var jump_speed: int
@export var jump_height: int
#physics variables
	#use this to calculate position changes, 4x as big as global_position, do not use global_position itself
	#meant to be used when you need position changes smaller than 1 pixel
var upscaled_position: Vector2i
#velocity, in quarter pixels per frame
var velocity: Vector2i
@export var gravity: int
const floor_height: int = 560
var decel: int = 1
#state machine variables
var state: String = "neutral"


#methods for things idkk
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
		if get_input_vector().x != 0:
			velocity.x = get_input_vector().x * walk_speed

func end_of_frame() -> void:
	global_position = Vector2i(upscaled_position / 4)
	print(get_input_vector())
	
