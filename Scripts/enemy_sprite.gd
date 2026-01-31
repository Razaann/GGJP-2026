extends Sprite2D

@export var sprite_width: int = 192
@export var sprite_height: int = 192
@export var total_variants: int = 6

func _ready() -> void:
	randomize_enemy_sprite()

func randomize_enemy_sprite() -> void:
	# Generate random index (0-5 for 6 variants)
	var random_index = randi_range(0, total_variants - 1)
	
	# Enable region if not already enabled
	region_enabled = true
	
	# Calculate the region rectangle
	var x_pos = random_index * sprite_width
	region_rect = Rect2(x_pos, 0, sprite_width, sprite_height)
	
	print("Enemy sprite set to variant: ", random_index + 1)
