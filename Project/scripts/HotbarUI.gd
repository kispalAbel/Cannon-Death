
extends CanvasLayer

const SLOT_SIZE := Vector2(48, 48)
const SLOT_GAP := 5

var slot_panels: Array[Panel] = []
var slot_icons: Array[TextureRect] = []


func _ready() -> void:
	var container := HBoxContainer.new()
	container.add_theme_constant_override("separation", SLOT_GAP)
	container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.offset_top = -65
	container.offset_bottom = -12

	add_child(container)

	for i in range(Global.SLOT_COUNT):
		var panel := Panel.new()
		panel.custom_minimum_size = SLOT_SIZE

		var icon := TextureRect.new()
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 5
		icon.offset_top = 5
		icon.offset_right = -5
		icon.offset_bottom = -5
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		panel.add_child(icon)
		container.add_child(panel)

		slot_panels.append(panel)
		slot_icons.append(icon)

	Global.hotbar_changed.connect(update_hotbar)
	update_hotbar()


func update_hotbar() -> void:
	for i in range(Global.SLOT_COUNT):
		var item = Global.hotbar[i]

		if item != null:
			slot_icons[i].texture = item.icon
		else:
			slot_icons[i].texture = null

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.12, 0.12, 0.85)
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2

		if i == Global.selected_slot:
			style.border_color = Color.WHITE
		else:
			style.border_color = Color(0.4, 0.4, 0.4)

		slot_panels[i].add_theme_stylebox_override("panel", style)
