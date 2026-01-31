extends Node2D

# Card Number
@onready var number_label: Label = $CardSprite/Number
var card_value: int = 0

# Card Animation
@export var idle_bob_height := 6.0
@export var idle_bob_speed := 2.0
@export var idle_scale_amount := 0.03
@export var idle_rotation_amount := 0.02

var base_position: Vector2
var base_scale: Vector2
var base_rotation: float
var t := 0.0


func setup(value: int):
	card_value = value
	# We use call_deferred or check if ready to ensure the label exists
	if is_inside_tree():
		number_label.text = str(value)
	else:
		await ready 
		number_label.text = str(value)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	number_label.modulate = Color("#1a1a1a")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_idle_anim(delta)

func _idle_anim(delta):
	t += delta * idle_bob_speed
	
	# Change 'position.y' to '$CardSprite.position.y'
	# This leaves the root position (the one you set to 200) alone!
	$CardSprite.position.y = sin(t) * idle_bob_height
	
	# Do the same for scale and rotation if you want them to be relative
	var s = 1.0 + sin(t * 0.8) * idle_scale_amount
	$CardSprite.scale = Vector2(s, s)
	
	$CardSprite.rotation = sin(t * 0.6) * idle_rotation_amount
