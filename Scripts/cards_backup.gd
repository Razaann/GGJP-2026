extends Node2D

@onready var cardd_1: Sprite2D = $Cardd1
var is_dragging := false
var base_position := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_mouse_entered() -> void:
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
