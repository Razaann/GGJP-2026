extends Node2D


const collision_mask_card = 1
const collision_mask_card_slot = 2
var is_dragging = null
var drag_start_position := Vector2.ZERO
var screen_size
var drag_offset := Vector2.ZERO

var card_current_slot := {}

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
				start_drag(card)
		else:
			finish_drag()


func start_drag(card):
	is_dragging = card
	is_dragging.z_index = 10
	is_dragging.scale = Vector2(1, 1)
	
	drag_start_position = card.global_position
	drag_offset = card.global_position - get_global_mouse_position()


func finish_drag():
	#if is_dragging == null:
		#return
	#
	#is_dragging.scale = Vector2(1.05, 1.05)
	#is_dragging.z_index = 0
	#
	#var card_slot_found = _raycast_card_slot_check()
	#
	#if card_slot_found and not card_slot_found.card_in_slot:
		#is_dragging.position = card_slot_found.position
		#card_slot_found.card_in_slot = true
	#else:
		##is_dragging.global_position = drag_start_position
		#var tween = create_tween()
		#tween.tween_property(
			#is_dragging,
			#"global_position",
			#drag_start_position,
			#0.15
		#).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#
	#is_dragging = null
	if is_dragging == null:
		return
	
	var card = is_dragging
	card.scale = Vector2(1.05, 1.05)
	card.z_index = 0
	var target_slot = _raycast_card_slot_check()
	
	# === VALID DROP ===
	if target_slot and target_slot.is_empty():
		
		# If card was already in a slot, free that slot
		if card_current_slot.has(card):
			card_current_slot[card].card_in_slot = null
		
		# Snap card to slot
		card.global_position = target_slot.global_position
		target_slot.card_in_slot = card
		card_current_slot[card] = target_slot
	
	# === INVALID DROP ===
	else:
		var tween = create_tween()
		tween.tween_property(
			card,
			"global_position",
			drag_start_position,
			0.15
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	is_dragging = null


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

func _raycast_card_slot_check():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask_card_slot
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
