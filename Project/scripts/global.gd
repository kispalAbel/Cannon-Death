
extends Node

signal hotbar_changed
signal selected_item_changed(item)

const SLOT_COUNT = 10

var hotbar = []
var selected_slot = 0

@export var main_level: TileMapLayer

var levels_container: Node
var current_level: TileMapLayer
var all_levels: Array[TileMapLayer] = []


func _ready() -> void:
	hotbar.resize(SLOT_COUNT)

	levels_container = get_node_or_null("Levels")

	if levels_container == null:
		push_error("Global: Levels not found!")
		return

	for level in levels_container.get_children():
		all_levels.append(level)

	if main_level == null or not all_levels.has(main_level):
		push_error("Global: Main Level is missing or invalid!")
		return

	current_level = main_level

	for level in all_levels:
		if level != main_level:
			levels_container.remove_child(level)

	move_player_to_spawn(main_level)


# HOTBAR

func add_item(item) -> bool:
	if item == null:
		return false

	for i in range(SLOT_COUNT):
		if hotbar[i] == null:
			hotbar[i] = item
			hotbar_changed.emit()
			return true

	return false


func select_slot(index: int) -> void:
	if index < 0 or index >= SLOT_COUNT:
		return

	selected_slot = index
	hotbar_changed.emit()
	selected_item_changed.emit(get_selected_item())


func get_selected_item():
	return hotbar[selected_slot]


func remove_selected_item():
	var item = hotbar[selected_slot]
	hotbar[selected_slot] = null
	hotbar_changed.emit()
	selected_item_changed.emit(null)
	return item


func select_next() -> void:
	select_slot((selected_slot + 1) % SLOT_COUNT)


func select_previous() -> void:
	select_slot((selected_slot - 1 + SLOT_COUNT) % SLOT_COUNT)


# LEVEL MANAGEMENT

func change_level(target_level: TileMapLayer) -> void:
	if levels_container == null:
		return

	if target_level == null or not all_levels.has(target_level):
		push_error("Global: Invalid target level!")
		return

	if target_level == current_level:
		return

	levels_container.remove_child(current_level)
	levels_container.add_child(target_level)

	current_level = target_level

	move_player_to_spawn(target_level)

	print("Level changed to: ", target_level.name)


# PLAYER SPAWN

func move_player_to_spawn(level: TileMapLayer) -> void:
	var player = get_node_or_null("Player")

	if player == null:
		push_error("Global: Player not found!")
		return

	player.global_position = level.to_global(level.spawn_position)
