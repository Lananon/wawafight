extends Node2D

class_name animation_step

#add an animation_step called LOOP at the end of your animation if you want it to loop

@export var frame: int
@export var animation_frame: int

@export var is_new_attack: bool

@export var hitstun: int
@export var blockstun: int
@export var block_type: Array = ["HIGH", "LOW", "AIR"]
