extends Node2D

@export var idle_bob_height := 6.0
@export var idle_bob_speed := 2.0
@export var idle_scale_amount := 0.03
@export var idle_rotation_amount := 0.02

var base_position: Vector2
var base_scale: Vector2
var base_rotation: float
var t := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_position = position
	base_scale = scale
	base_rotation = rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_idle_anim(delta)

func _idle_anim(delta):
	t += delta * idle_bob_speed
	
	# vertical float
	position.y = base_position.y + sin(t) * idle_bob_height
	
	# breathing scale
	var s = 1.0 + sin(t * 0.8) * idle_scale_amount
	scale = base_scale * s
	
	# tiny sway
	rotation = base_rotation + sin(t * 0.6) * idle_rotation_amount
