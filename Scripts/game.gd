extends Node2D

const CARD_SCENE = preload("res://Scenes/cardd.tscn")
const CARD_VALUE = preload("res://Scenes/card_value.tscn")
@onready var player_hand: Node2D = $PlayerHand

var score_ui_instance = null

func _ready() -> void:
	score_ui_instance = CARD_VALUE.instantiate()
	add_child(score_ui_instance)
	# Position it near the player's hand (adjust these numbers to fit your art)
	score_ui_instance.position = Vector2(900, 600)
	draw_card()
	draw_card()



func draw_card():
	var card_count = player_hand.get_child_count() + 1
	if card_count >= 6: # Limits to 5 cards (0, 1, 2, 3, 4)
		return
	var random_value = randi_range(1, 10)
	var new_card = CARD_SCENE.instantiate()
	
	# 1. Add to tree and setup
	player_hand.add_child(new_card)
	new_card.setup(random_value)
	
	# 2. Define Positions
	var final_x = 900 - (card_count * 150)
	var final_y = 600
	var start_y = 800 # Start below the screen
	
	# 3. Set the Initial "Off-screen" Position
	new_card.position = Vector2(final_x, start_y)
	# Start it invisible or slightly transparent for extra polish
	new_card.modulate.a = 0 
	
	# 4. Create the Tween
	var tween = create_tween()
	
	# Slide Up: Use TRANS_BACK and EASE_OUT for a "bouncy" landing
	tween.tween_property(new_card, "position", Vector2(final_x, final_y), 0.4)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	# Fade In: Parallel to the movement
	tween.parallel().tween_property(new_card, "modulate:a", 1.0, 0.2)
	tween.tween_callback(update_score)
	
	print("Drawing card value: ", random_value)


func update_score():
	var total_score = 0
	var cards = player_hand.get_children()
	
	# Loop through every card in the hand and add its value
	for card in cards:
		# Ensure the card script has 'card_value' variable exposed
		if "card_value" in card:
			total_score += card.card_value
	
	print("Current Total Score: ", total_score)
	
	# Update the UI
	if score_ui_instance != null:
		score_ui_instance.update_display(total_score)


func _on_draw_buttonn_pressed() -> void:
	draw_card()
