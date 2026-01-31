extends Node2D

# Card Number
@onready var number_label: Label = $TotalCardSprite2D/TotalNumberLabel
@onready var card_sprite: Sprite2D = $TotalCardSprite2D
var card_value: int = 0

# Card Animation
@export var idle_bob_height := 6.0
@export var idle_bob_speed := 2.0	

var base_position: Vector2
var base_scale: Vector2
var base_rotation: float
var t := 0.0


func setup(value: int):
	card_value = value
	if not is_inside_tree(): await ready
	number_label.text = str(value)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	number_label.modulate = Color("#9e0000")


func update_display(current_score: int):
	#number_label.text = "= " + str(current_score)
	number_label.text = str(current_score)
	number_label.modulate = Color("#9e0000")
	
	# Visual Feedback: Turn RED if they bust
	#if current_score > 13:
		#number_label.modulate = Color("#9e0000")
	#else:
		#number_label.modulate = Color("#9e0000")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_idle_anim(delta)

func _idle_anim(delta):
	t += delta * idle_bob_speed
	# We animate the Sprite's local position, NOT the root's position.
	card_sprite.position.y = sin(t) * idle_bob_height
	# Optional: Subtle rotation on the sprite
	card_sprite.rotation = sin(t * 0.6) * 0.02
