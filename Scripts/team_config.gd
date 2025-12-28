extends Control

var pack_state = {}

@onready var team_count = $Panel/VBox/Row/TeamCount
@onready var teams_container = $Panel/VBox/Teams

func _ready():
	team_count.clear()
	team_count.add_item("2 times")
	team_count.add_item("3 times")
	team_count.add_item("4 times")
	team_count.select(0) # 2 times por padrão
	_rebuild_teams(2)

func _on_team_count_item_selected(index: int):
	var count = 2 + index
	_rebuild_teams(count)

func _rebuild_teams(count: int):
	for child in teams_container.get_children():
		child.queue_free()
	for i in range(count):
		var hb = HBoxContainer.new()
		hb.add_theme_constant_override("separation", 10)
		var name_label = Label.new()
		name_label.text = "Nome do Time %d:" % (i + 1)
		var name_edit = LineEdit.new()
		name_edit.name = "Name%d" % i
		name_edit.placeholder_text = "Time %c" % (65 + i)
		var color_label = Label.new()
		color_label.text = "Cor:"
		var color = ColorPickerButton.new()
		color.name = "Color%d" % i
		color.color = Color.from_hsv(float(i) / max(1, count), 0.7, 1.0)
		hb.add_child(name_label)
		hb.add_child(name_edit)
		hb.add_child(color_label)
		hb.add_child(color)
		teams_container.add_child(hb)

func _on_cancel_pressed():
	get_tree().change_scene_to_file("res://Scenes/mode_selector.tscn")

func _on_start_pressed():
	var names: Array[String] = []
	var colors: Array[Color] = []
	for i in range(teams_container.get_child_count()):
		var hb: HBoxContainer = teams_container.get_child(i)
		var name_edit: LineEdit = hb.get_node("Name%d" % i)
		var color_btn: ColorPickerButton = hb.get_node("Color%d" % i)
		var nm = name_edit.text if name_edit.text.strip_edges() != "" else name_edit.placeholder_text
		names.append(nm)
		colors.append(color_btn.color)
	var team_config = {
		"enabled": true,
		"num_teams": names.size(),
		"team_names": names,
		"team_colors": colors
	}
	var scene = load("res://Scenes/generate_cards.tscn")
	var next = scene.instantiate()
	next.set("pack_state", pack_state)
	next.set("game_mode", "times")
	next.set("team_config", team_config)
	var current = get_tree().current_scene
	get_tree().root.add_child(next)
	get_tree().set_current_scene(next)
	if current and is_instance_valid(current):
		current.queue_free()

