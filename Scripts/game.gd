extends Node2D

const CARD_SCENE = preload("res://Scenes/cardd.tscn")
const CARD_VALUE = preload("res://Scenes/card_value.tscn")

@onready var player_hand: Node2D = $PlayerHand
@onready var enemy_hand: Node2D = $EnemyHand

@onready var end_button: TextureButton = $UI/EndButton
@onready var draw_buttonn: TextureButton = $UI/DrawButtonn

@onready var ui_label: Label = $UI/UILabel

var score_ui_player = null
var score_ui_enemy = null

func _ready() -> void:
	# Player card set up
	score_ui_player = CARD_VALUE.instantiate()
	add_child(score_ui_player)
	score_ui_player.position = Vector2(900, 600)
	
	# Enemy card set up
	score_ui_enemy = CARD_VALUE.instantiate()
	add_child(score_ui_enemy)
	score_ui_enemy.position = Vector2(900, 120)
	
	ui_label.modulate = Color("#d9d9d9")
	
	draw_card()
	draw_card()
	draw_enemy_card()


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


func draw_enemy_card():
	var card_count = enemy_hand.get_child_count() + 1
	if card_count >= 6: return
	
	var random_value = randi_range(1, 10)
	var new_card = CARD_SCENE.instantiate()
	
	enemy_hand.add_child(new_card)
	new_card.setup(random_value)
	
	var final_x = 900 - (card_count * 150) 
	var final_y = 120 # Top of screen
	var start_y = -120 # Start ABOVE the screen
	
	new_card.position = Vector2(final_x, start_y)
	new_card.modulate.a = 0 
	
	# 4. Create the Tween
	var tween = create_tween()
	
	# Slide Up: Use TRANS_BACK and EASE_OUT for a "bouncy" landing
	tween.tween_property(new_card, "position", Vector2(final_x, final_y), 0.4)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	# Fade In: Parallel to the movement
	tween.parallel().tween_property(new_card, "modulate:a", 1.0, 0.2)
	tween.tween_callback(update_enemy_score)


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
	if score_ui_player != null:
		score_ui_player.update_display(total_score)
	
	if total_score > 21:
		print("INSTANT BUST!")
		ui_label.text = str("YOU BUSTED")
		# 1. Disable buttons immediately
		draw_buttonn.disabled = true
		end_button.disabled = true
		await get_tree().create_timer(1.0).timeout
		evaluate_winner()

func update_enemy_score():
	var total_score = 0
	var cards = enemy_hand.get_children()
	
	for card in cards:
		if "card_value" in card:
			total_score += card.card_value
	
	if score_ui_enemy != null:
		score_ui_enemy.update_display(total_score)


func start_enemy_turn():
	print ("Enemy Turn")
	
	while true:
		var current_enemy_score = get_hand_total(enemy_hand)
		
		print ("Enemy Score", current_enemy_score)
		
		if current_enemy_score >= 17 or current_enemy_score > 21:
			break
		
		draw_enemy_card()
		await get_tree().create_timer(1.0).timeout
		
	evaluate_winner()


func get_hand_total(hand_node):
	var total = 0
	for card in hand_node.get_children():
		if "card_value" in card: total += card.card_value
	return total


func evaluate_winner():
	var player_score = get_hand_total(player_hand)
	var enemy_score = get_hand_total(enemy_hand)
	
	print("--- COMBAT RESULT ---")
	print("Player: ", player_score, " vs Enemy: ", enemy_score)
	
	var damage = 0
	
	# Scenario 1 Player bust
	if player_score > 21:
		print("PLAYER BUSTED! Enemy attacks freely.")
		ui_label.text = str("Enemy attacks freely")
		# Penalty: Enemy hits you with their full score? Or a flat amount?
		damage = enemy_score 
		take_damage(damage)
		await get_tree().create_timer(3.0).timeout # Let player read the result
		restart_round()
		return
	
	# Scenario 2 Enemy bust
	if enemy_score > 21:
		print("ENEMY BUSTED! Player attacks freely.")
		ui_label.text = str("ENEMY BUSTED! You attacks freely")
		damage = player_score
		deal_damage(damage)
		await get_tree().create_timer(3.0).timeout # Let player read the result
		restart_round()
		return
	
	# Scenario 3 Compare score
	if player_score > enemy_score:
		damage = player_score - enemy_score
		print("Player Wins! Dealing ", damage, " damage.")
		ui_label.text = str("Player Wins! Dealing ", damage, " damage")
		deal_damage(damage)
		await get_tree().create_timer(3.0).timeout # Let player read the result
		restart_round()
		return
	elif enemy_score > player_score:
		damage = enemy_score - player_score
		print("Enemy Wins! Taking ", damage, " damage.")
		ui_label.text = str("Enemy Wins! Taking ", damage, " damage")
		take_damage(damage)
		await get_tree().create_timer(3.0).timeout # Let player read the result
		restart_round()
		return
	else:
		print("It's A Draw")
		ui_label.text = str("It's A Draw")
		await get_tree().create_timer(3.0).timeout # Let player read the result
		restart_round()
		return



func restart_round():
	print("--- STARTING NEW ROUND ---")
	
	# 1. Create a parallel tween so all cards move at once
	var tween = create_tween().set_parallel(true)
	
	# 2. Animate Player Cards (Move Down & Fade Out)
	for card in player_hand.get_children():
		tween.tween_property(card, "position:y", 800, 0.5)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(card, "modulate:a", 0.0, 0.3)
	
	# 3. Animate Enemy Cards (Move Up & Fade Out)
	for card in enemy_hand.get_children():
		tween.tween_property(card, "position:y", -200, 0.5)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(card, "modulate:a", 0.0, 0.3)
	
	ui_label.text = str("")
	
	# 4. Wait for animation to finish
	await tween.finished
	
	# 5. Delete the old card nodes
	for card in player_hand.get_children(): card.queue_free()
	for card in enemy_hand.get_children(): card.queue_free()
	
	# 6. Reset Scores Visually
	score_ui_player.update_display(0)
	score_ui_enemy.update_display(0)
	
	# 7. Small pause before dealing new cards
	await get_tree().create_timer(0.3).timeout
	
	# 8. Setup next round
	draw_card()
	await get_tree().create_timer(0.2).timeout
	draw_card()
	draw_enemy_card()
	
	# 9. Re-enable buttons
	draw_buttonn.disabled = false
	end_button.disabled = false


# Placeholder functions for your future HP system
func take_damage(amount: int):
	print("Ouch! Took ", amount, " damage.")
	# Add your HP reduction code here later

func deal_damage(amount: int):
	print("Bam! Dealt ", amount, " damage.")
	# Add enemy HP reduction code here later


func _on_draw_buttonn_pressed() -> void:
	draw_card()


func _on_end_button_pressed() -> void:
	print("Player finished turn. Enemy thinking...")
	draw_buttonn.disabled = true
	end_button.disabled = true
	
	start_enemy_turn()
