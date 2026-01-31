extends Node2D

const CARD_SCENE = preload("res://Scenes/cardd.tscn")
@onready var player_hand: Node2D = $PlayerHand


func _ready() -> void:
	print ("Hello World")
	draw_card()



func draw_card():
		# 2. Generate a random value (1-10)
		var random_value = randi_range(1, 10)
		# 3. Create the instance
		var new_card = CARD_SCENE.instantiate()
		# Position logic: Offset each new card so they don't stack perfectly
		var card_count = player_hand.get_child_count() + 1
		# 4. Add it to the tree BEFORE calling setup
		if card_count < 16:
			player_hand.add_child(new_card)
			# 5. Set the number and position
			new_card.setup(random_value)
			new_card.position = Vector2(card_count * 80, 600)
			print (new_card.position)


func _on_draw_button_pressed() -> void:
	draw_card()
