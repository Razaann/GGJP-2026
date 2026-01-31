extends Node2D


@export var idle_bob_height := 6.0
@export var idle_bob_speed := 2.0
@export var idle_scale_amount := 0.03
@export var idle_rotation_amount := 0.02


var base_position: Vector2
var base_scale: Vector2
var base_rotation: float
var t := 0.0

var card_manager

var is_dragging := false
	
#signal hovered
#signal hovered_off


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_position = position
	base_scale = scale
	base_rotation = rotation


func setup(manager):
	card_manager = manager


func set_base_position(pos: Vector2) -> void:
	base_position = pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dragging:
		return  # disable idle while dragging
	
	t += delta * idle_bob_speed
	
	# vertical float
	position.y = base_position.y + sin(t) * idle_bob_height
	
	# breathing scale
	var s = 1.0 + sin(t * 0.8) * idle_scale_amount
	scale = base_scale * s
	
	# tiny sway
	rotation = base_rotation + sin(t * 0.6) * idle_rotation_amount


func _on_area_2d_mouse_entered() -> void:
	print("Hello")
	if is_dragging: return
	z_index = 10
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "position:y", base_position.y, 0.1)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)


func _on_area_2d_mouse_exited() -> void:
	if is_dragging: return
	z_index = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "position:y", base_position.y, 0.1)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
