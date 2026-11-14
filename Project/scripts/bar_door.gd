
extends Node2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var door_collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var detection_area: Area2D = $Area2D

@export var block_players: bool = true
@export var item_required: bool = false
@export var required_item: Item
@export var remove_used_item: bool = false
@export var scene_to_load: Node

var is_opening := false
var is_open := false


func _ready() -> void:
	door_collision.set_deferred("disabled", not block_players)

	animation.play("closed")

	detection_area.body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node2D) -> void:
	print("Player detected!")
	open_door()


func open_door() -> void:
	if is_opening or is_open:
		return

	if item_required:
		var selected_item = Global.get_selected_item()

		if selected_item == null or selected_item != required_item:
			return

	is_opening = true

	if item_required and remove_used_item:
		Global.remove_selected_item()

	animation.play("open")

	is_opening = false
	is_open = true

	door_collision.set_deferred("disabled", true)

	door_finished()


func door_finished() -> void:
	if block_players:
		print("Bar door opened!")
	else:
		print("Bar door opened! Loading new level...")
		load_level()


func load_level() -> void:
	if scene_to_load == null:
		push_error("BarDoor: No scene assigned to scene_to_load!")
		return

	get_tree().current_scene.change_level(scene_to_load)
