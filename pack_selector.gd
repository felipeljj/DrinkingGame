extends Control

var pack_state = {
	"classico": true,
	"nonsense": false,
	"weirdo": false,
	"languages": false,
	"pool": false,
}
@onready var pack_panels = {
	"classico": $MarginContainer/ScrollContainer/HBoxContainer/Classic,
	"nonsense": $MarginContainer/ScrollContainer/HBoxContainer/NonSense,
	"weirdo": $MarginContainer/ScrollContainer/HBoxContainer/Weirdo,
	"languages": $MarginContainer/ScrollContainer/HBoxContainer/Languages,
	"pool": $MarginContainer/ScrollContainer/HBoxContainer/Pool
}
func _ready():
	for pack_name in pack_state.keys():
		update_pack_visual(pack_name)
	
func update_pack_visual(pack_name):
	var panel = pack_panels[pack_name]
	var is_active = pack_state[pack_name]
	panel.modulate = Color (1,1,1,1) if is_active else Color (1,1,1,0.5)

func _on_pack_panel_pressed(pack_name):
	pack_state[pack_name] = !pack_state[pack_name]
	update_pack_visual(pack_name)

func _on_classic_pressed() -> void:
	_on_pack_panel_pressed("classico")
	
func _on_nonsense_pressed() -> void:
	_on_pack_panel_pressed("nonsense")
	
func _on_weirdo_pressed() -> void:
	_on_pack_panel_pressed("weirdo")

func _on_languages_pressed() -> void:
	_on_pack_panel_pressed("languages")
	
func _on_pool_pressed() -> void:
	_on_pack_panel_pressed("languages")

	
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
	
func _process(delta: float) -> void:
	pass

func _on_começar_pressed() -> void:
	# Carrega a cena de geração de cartas
	var packed_scene = load("res://generate_cards.tscn")  # Carrega a cena como PackedScene
	var next_scene = packed_scene.instantiate()  # Cria uma instância da cena

	# Passa o estado dos pacotes para a nova cena
	next_scene.pack_state = pack_state

	# Muda para a nova cena
	get_tree().root.add_child(next_scene)  # Adiciona a nova cena à árvore de cenas
	get_tree().current_scene.queue_free()  # Remove a cena atuala cena atual
