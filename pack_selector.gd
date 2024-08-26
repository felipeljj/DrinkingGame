extends Control

var pack_state = {
	"classico": true,
	"nonsense": false,
	"cuzinho": false
}

@onready var pack_panels = {
	"classico": $MarginContainer/ScrollContainer/HBoxContainer/Classic,
	"nonsense": $MarginContainer/ScrollContainer/HBoxContainer/NonSense,
	"cuzinho": $MarginContainer/ScrollContainer/HBoxContainer/Cuzinho,
}

# Called when the node enters the scene tree for the first time.
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
	
func _on_cuzinho_pressed() -> void:
	_on_pack_panel_pressed("cuzinho")
	


func _process(delta: float) -> void:
	pass
