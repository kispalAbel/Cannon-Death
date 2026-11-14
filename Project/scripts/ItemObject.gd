extends Area2D

@export var item: Item

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if item != null:
		sprite.texture = item.icon
