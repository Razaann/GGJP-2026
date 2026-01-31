extends Node2D


const collision_mask_card = 1
var is_dragging = null
var screen_size
var drag_offset := Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = get_global_mouse_position() + drag_offset
		is_dragging.global_position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = _raycast_card_check()
			if card:
				is_dragging = card
				is_dragging.z_index = 10
				drag_offset = card.global_position - get_global_mouse_position()
		else:
			is_dragging.z_index = 0
			is_dragging = null


#func connect_card_signals(card):
	#card.connect("hovered", on_hovered_over_card)
	#card.connect("hovered_off", on_hovered_off_card)
#
#
#func on_hovered_over_card(card):
	#print("hovered")
#
#
#func on_hovered_off_card(card):
	#print("hovered_off")


func _raycast_card_check():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask_card
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
