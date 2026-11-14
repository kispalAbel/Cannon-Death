extends Area2D

@export var game_over_label: Label

var game_over := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if game_over:
		return

	if body.name == "Player":
		game_over = true
		game_over_label.text = "Game Over! Nyertél!"
		game_over_label.visible = true
		print("Game Over! Nyertél!")
