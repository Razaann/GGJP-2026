extends Node2D

enum MaskType { 
	NONE, 
	MANIAC, 
	NARCISSISM, 
	VENGEANCE, 
	OBSESSION, 
	SMUG, 
	EUPHORIA, 
	BLACK_RAGE,
	SHAME, 
	TORMENT 
}

# CHANGE THIS to test different masks!
var current_mask: MaskType = MaskType.NONE 

# State variables for specific masks
var damage_taken_last_turn: bool = false # For Vengeance

const CARD_SCENE = preload("res://Scenes/cardd.tscn")
const CARD_VALUE = preload("res://Scenes/card_value.tscn")

@onready var player_hand: Node2D = $PlayerHand
@onready var enemy_hand: Node2D = $EnemyHand

@onready var end_button: TextureButton = $UI/EndButton
@onready var draw_buttonn: TextureButton = $UI/DrawButtonn

@onready var ui_label: Label = $UI/UILabel
@onready var player_hp_label: Label = $UI/PlayerHP
@onready var enemy_hp_label: Label = $UI/EnemyHP


@onready var whoosh_sfx: AudioStreamPlayer2D = $SFX/WhooshSFX
@onready var whoosh_sfx_2: AudioStreamPlayer2D = $SFX/WhooshSFX2

@onready var whoosh_sounds = [
	$SFX/WhooshSFX, 
	$SFX/WhooshSFX2, 
	$SFX/WhooshSFX3
	]

var MAX_HP = 25

var player_hp = MAX_HP
var enemy_hp = MAX_HP

var score_ui_player = null
var score_ui_enemy = null

@onready var player_sprite: Sprite2D = $Characters/PlayerChara/Sprite2D
@onready var enemy_sprite: Sprite2D = $Characters/EnemyChara/Sprite2D

@onready var music_bg: AudioStreamPlayer2D = $SFX/MusicBG

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
	
	music_bg.stream = load("res://Assets/audio/boss battle.wav")
	music_bg.play()  # If not set to autoplay
	
	update_hp_ui()
	
	draw_card()
	draw_card()
	draw_enemy_card()


func draw_card():
	var card_count = player_hand.get_child_count() + 1
	if card_count >= 5: # Limits to 5 cards (0, 1, 2, 3, 4)
		return
	if current_mask == MaskType.SHAME:
		take_damage(1)
		print("Mask of Shame: Took 1 damage for drawing.")
		# If you die from drawing, stop here!
		if player_hp <= 0: return
	
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
	
	play_random_whoosh()
	
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
	if enemy_hand.get_child_count() > 5: 
		return
	
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
	
	play_random_whoosh()
	
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
	
	while enemy_hand.get_child_count() < 4:
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
	
	var player_limit = 21
	if current_mask == MaskType.MANIAC:
		player_limit = 19
	
	# --- 1. CHECK BUSTS ---
	if player_score > player_limit:
		print("PLAYER BUSTED!")
		damage = enemy_score
		
		# Mask of Narcissism: Extra punishment for losing
		if current_mask == MaskType.NARCISSISM:
			damage += 2
			
		take_damage(damage)
		damage_taken_last_turn = true # Mark for Vengeance next turn
	
	elif enemy_score > 21:
		print("ENEMY BUSTED!")
		damage = calculate_attack_damage(player_score)
		deal_damage(damage)
		damage_taken_last_turn = false
	
	else:
		if player_score > enemy_score:
			damage = calculate_attack_damage(player_score - enemy_score)
			deal_damage(damage)
			damage_taken_last_turn = false
		
		elif enemy_score > player_score:
			damage = enemy_score - player_score
			take_damage(damage)
			damage_taken_last_turn = true
		
		else:
			# --- MASK: SMUG (Win Ties) ---
			if current_mask == MaskType.SMUG:
				print("Mask of Smug: Tie becomes a WIN!")
				damage = calculate_attack_damage(1) # Deal 1 damage on tie
				deal_damage(damage)
			else:
				print("It's a Draw")
	
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


# Helper to calculate bonus damage
func calculate_attack_damage(base_dmg: int) -> int:
	var final_dmg = base_dmg
	
	match current_mask:
		MaskType.MANIAC:
			final_dmg += 2
		MaskType.TORMENT:
			final_dmg += 5
		MaskType.BLACK_RAGE:
			final_dmg += 3 # High aggression
		MaskType.VENGEANCE:
			if damage_taken_last_turn:
				final_dmg *= 2 # Double damage if hurt previously!
				print("Vengeance Activated!")
				
	# --- MASK: NARCISSISM (Heal on Win) ---
	if current_mask == MaskType.NARCISSISM and final_dmg > 0:
		heal_player(2)
		
	return final_dmg

func heal_player(amount: int):
	# 1. Increase HP
	player_hp += amount

	# 2. Safety Clamp: Never go above Max HP
	# (Note: If you are using the Torment mask, make sure MAX_HP is a variable, not a const!)
	if player_hp > MAX_HP:
		player_hp = MAX_HP
		
	print("Healed! HP is now: ", player_hp)

	# 3. Visual Feedback (Flash Green)
	if player_sprite:
		var tween = create_tween()
		# Flash to Green
		tween.tween_property(player_sprite, "modulate", Color(0.5, 2.0, 0.5), 0.2) 
		# Fade back to Normal
		tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.2)

	# 4. Update the UI
	update_hp_ui()


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
	player_hp -= amount
	print("Ouch! Player took ", amount, " damage. HP: ", player_hp)
	
	# SHAKE THE PLAYER (The Victim)
	if player_sprite:
		play_shake_anim(player_sprite)
		
		# Flash Red for extra "Pain" feel
		var tween = create_tween()
		tween.tween_property(player_sprite, "modulate", Color(10, 0, 0), 0.1) # Flash BRIGHT Red
		tween.tween_property(player_sprite, "modulate", Color.WHITE, 0.2)
	
	# Visual Shake? Flash Red? Add juice here later.
	update_hp_ui()
	check_game_over()

func deal_damage(amount: int):
	enemy_hp -= amount
	print("Bam! Enemy took ", amount, " damage. HP: ", enemy_hp)
	
	# SHAKE THE ENEMY (The Victim)
	if enemy_sprite:
		play_shake_anim(enemy_sprite)
		
		# Flash White/Red for impact
		var tween = create_tween()
		tween.tween_property(enemy_sprite, "modulate", Color(10, 10, 10), 0.1) # Flash BRIGHT White
		tween.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.2)
	
	update_hp_ui()
	check_game_over()

func check_game_over():
	if player_hp <= 0:
		print("GAME OVER - YOU DIED")
		game_over("LOSE")

	elif enemy_hp <= 0:
		print("VICTORY - ENEMY SLAIN")
		game_over("WIN")

func game_over(result: String):
	# Stop the game flow
	draw_buttonn.disabled = true
	end_button.disabled = true
	
	# Create a simple Tween to show a "Fade Out" or just restart
	if result == "WIN":
		# Maybe show a "You Win" label here?
		pass 
	else:
		# Maybe show a "You Died" label here?
		pass
	# For now, just reload the scene after 2 seconds
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

func play_random_whoosh():
	var random_sound = whoosh_sounds.pick_random()
	random_sound.play()


func update_hp_ui():
	if player_hp_label:
		player_hp_label.text = "HP: " + str(max(player_hp, 0)) + "/" + str(MAX_HP)
	
	if enemy_hp_label:
		enemy_hp_label.text = "HP: " + str(max(enemy_hp, 0)) + "/" + str(MAX_HP)

func play_shake_anim(target: Node2D, intensity: float = 10.0, duration: float = 0.4):
	# 1. Store original values so we don't "drift"
	var original_scale = target.scale
	# We shake 'offset' so we don't mess up the actual 'position' of the character
	# Ensure your Sprite2D offset is normally (0,0)
	var original_offset = target.offset 
	
	var tween = create_tween()
	
	# --- PHASE 1: THE SWELL (Balatro Style) ---
	# Scale up slightly right before the shake (anticipation/impact)
	$SFX/AttackSFX.play()
	tween.tween_property(target, "scale", original_scale * 1.2, 0.05)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# --- PHASE 2: THE SHAKE ---
	# We manually shake for the duration
	var steps = 10 # How many "shakes" happen
	var step_duration = duration / steps
	
	for i in range(steps):
		# Create a random offset for "violent" vibration
		var random_x = randf_range(-intensity, intensity)
		var random_y = randf_range(-intensity, intensity)
		var random_rot = randf_range(-0.1, 0.1) # Slight rotation shake
		
		# Shake Position (Offset)
		tween.tween_property(target, "offset", Vector2(random_x, random_y), step_duration)
		
		# Parallel Shake Rotation
		tween.parallel().tween_property(target, "rotation", random_rot, step_duration)
	
	# --- PHASE 3: THE SNAP BACK ---
	# Reset everything to normal
	tween.tween_property(target, "scale", original_scale, 0.1)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(target, "offset", original_offset, 0.1)
	tween.parallel().tween_property(target, "rotation", 0.0, 0.1)


func apply_passive_mask_stats():
	MAX_HP = 25
	match current_mask:
		MaskType.TORMENT:
			MAX_HP = 12
			player_hp = 12
			print("Mask Of Torment: HP Halved")
		
		MaskType.EUPHORIA:
			# Start with a free low card
			print("Mask of Euphoria: Starting with extra card")
			draw_card()


func _on_draw_buttonn_pressed() -> void:
	draw_card()


func _on_end_button_pressed() -> void:
	print("Player finished turn. Enemy thinking...")
	draw_buttonn.disabled = true
	end_button.disabled = true
	
	start_enemy_turn()
