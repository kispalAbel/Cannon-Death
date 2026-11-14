
extends CharacterBody2D

@onready var timer: Timer = $Timer

const SPEED = 130.0
const AIR_ACCELERATION = 130.0
const GRAVITY = 980
const MAX_FALL_SPEED = 600.0
const JUMP_VELOCITY = -200.0

const GROUND_FRICTION = 1000.0
const AIR_DRAG = 30.0

const ITEM_OBJECT_SCENE = preload("res://scenes/item_object.tscn")

var nearby_items: Array[Area2D] = []

var Keys = {
	"jump": KEY_SPACE,
	"pickup": KEY_E,
	"drop": KEY_Q,
	"move": {
		"left": KEY_A,
		"right": KEY_D
	}
}


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == Keys["pickup"]:
			pickup_item()

		elif event.keycode == Keys["drop"]:
			drop_item()

		elif event.keycode >= KEY_1 and event.keycode <= KEY_9:
			Global.select_slot(event.keycode - KEY_1)

		elif event.keycode == KEY_0:
			Global.select_slot(9)

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Global.select_previous()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Global.select_next()


func pickup_item() -> void:
	if nearby_items.is_empty():
		return

	var item_object = nearby_items[0]

	if not is_instance_valid(item_object):
		nearby_items.erase(item_object)
		return

	if Global.add_item(item_object.item):
		nearby_items.erase(item_object)
		item_object.queue_free()


func drop_item() -> void:
	var item = Global.remove_selected_item()

	if item == null:
		return

	var item_object = ITEM_OBJECT_SCENE.instantiate()
	item_object.item = item

	get_tree().current_scene.add_child(item_object)

	item_object.global_position = global_position + Vector2(0 if not $AnimatedSprite2D.flip_h else 0, -10) #For future use. If we ever want to rely on the facing


func _on_pickup_area_area_entered(area: Area2D) -> void:
	if area is Area2D and area.get("item") != null:
		if not nearby_items.has(area):
			nearby_items.append(area)


func _on_pickup_area_area_exited(area: Area2D) -> void:
	nearby_items.erase(area)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		timer.start()
		velocity.y = move_toward(
			velocity.y,
			MAX_FALL_SPEED,
			GRAVITY * delta
		)

	if Input.is_key_pressed(Keys["jump"]) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := (
		float(Input.is_key_pressed(Keys["move"]["right"]))
		- float(Input.is_key_pressed(Keys["move"]["left"]))
	)

	if is_on_floor():
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, GROUND_FRICTION * delta)
	else:
		if direction:
			velocity.x = move_toward(
				velocity.x,
				direction * SPEED,
				AIR_ACCELERATION * delta
			)
		else:
			velocity.x = move_toward(
				velocity.x,
				0,
				AIR_DRAG * delta
			)

	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true

	if velocity.x:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

	move_and_slide()
