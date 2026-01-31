extends Node2D

const hand_count = 5
const card_scene_path = "res://Scenes/cards.tscn"
const card_width = 150
const hand_y_position = 600

@onready var card_manager: Node2D = $"../CardManager"

var player_hand = []
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().size.x / 2
	
	var card_scene = preload(card_scene_path)
	
	for i in range(hand_count):
		var new_card = card_scene.instantiate()
		card_manager.add_child(new_card)
		new_card.setup(card_manager)
		add_new_card_to_hand(new_card)


func add_new_card_to_hand(card):
	player_hand.insert(0, card)
	update_hand_positions()


func update_hand_positions():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), hand_y_position)
		var card = player_hand[i]
		card.set_base_position(new_position)
		animate_card_to_position(card, new_position)


func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * card_width
	return center_screen_x - total_width / 2 + index * card_width


func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
