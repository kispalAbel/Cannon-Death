
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
var player_in_range := false


func _ready() -> void:
	door_collision.set_deferred("disabled", not block_players)

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	animation.animation_finished.connect(_on_animation_finished)

	Global.hotbar_changed.connect(_on_hotbar_changed)


func _on_body_entered(body: Node2D) -> void:
	player_in_range = true
	print("Player detected!")
	open_door()


func _on_body_exited(body: Node2D) -> void:
	player_in_range = false


func _on_hotbar_changed() -> void:
	if player_in_range:
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


func _on_animation_finished() -> void:
	if animation.animation == "open":
		is_opening = false
		is_open = true

		door_collision.set_deferred("disabled", true)

		door_finished()


func door_finished() -> void:
	if block_players:
		print("Door opened!")
	else:
		print("Door opened! Loading new level...")
		load_level()


func load_level() -> void:
	if scene_to_load == null:
		push_error("Door: No scene assigned to scene_to_load!")
		return

	get_tree().current_scene.change_level(scene_to_load)
