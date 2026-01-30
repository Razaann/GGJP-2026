extends Control

var is_dragging: bool = false
var drag_offset := Vector2.ZERO
var original_position := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	print("Card ready, size:", size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_drag(event.position)
			print("P")
		else:
			stop_drag()


func start_drag(mouse_pos: Vector2):
	is_dragging = true
	drag_offset = mouse_pos
	original_position = global_position
	z_index = 100

func stop_drag():
	is_dragging = false
	z_index = 0
