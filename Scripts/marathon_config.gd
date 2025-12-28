extends Control

var pack_state = {}
var fast_mode: bool = false

@onready var type_opt = $Panel/VBox/Type
@onready var value_opt = $Panel/VBox/Value

func _ready():
	# Type options
	type_opt.clear()
	type_opt.add_item("Duração (minutos)")
	type_opt.add_item("Meta de cartas")
	type_opt.select(0)
	_refresh_values()

func _on_type_item_selected(index: int):
	_refresh_values()

func _refresh_values():
	value_opt.clear()
	if type_opt.get_selected_id() == 0 or type_opt.get_selected() == 0:
		for m in [15, 30, 45, 60]:
			value_opt.add_item(str(m))
		value_opt.select(1)
	else:
		for c in [20, 30, 40, 50, 60]:
			value_opt.add_item(str(c))
		value_opt.select(1)

func _on_cancel_pressed():
	get_tree().change_scene_to_file("res://Scenes/mode_selector.tscn")

func _on_start_pressed():
	var is_duration = (type_opt.get_selected() == 0)
	var val_text = value_opt.get_item_text(value_opt.get_selected())
	var n = int(val_text)
	var marathon_config = {
		"type": ("duration" if is_duration else "goal"),
		"value": n
	}
	var scene = load("res://Scenes/generate_cards.tscn")
	var next = scene.instantiate()
	next.set("pack_state", pack_state)
	next.set("fast_mode", fast_mode)
	next.set("game_mode", "maratona")
	next.set("marathon_config", marathon_config)
	var current = get_tree().current_scene
	get_tree().root.add_child(next)
	get_tree().set_current_scene(next)
	if current and is_instance_valid(current):
		current.queue_free()

