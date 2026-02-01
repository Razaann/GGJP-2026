extends Node

# Move the Enum here so ANY scene can see it
enum MaskType { 
	NONE, MANIAC, NARCISSISM, VENGEANCE, OBSESSION, 
	SMUG, EUPHORIA, BLACK_RAGE, SHAME, TORMENT 
}

# The Player's "Backpack"
var current_mask: MaskType = MaskType.NONE
var player_hp: int = 25
var max_hp: int = 25

# Reset everything when starting a fresh run from the Main Menu
func start_new_run():
	current_mask = MaskType.NONE
	player_hp = 25
	max_hp = 25
