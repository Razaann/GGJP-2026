extends Node2D


var card_in_slot: Node2D = null

func is_empty() -> bool:
	return card_in_slot == null
