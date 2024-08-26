extends Control

var pack_state = {
	"Classico": true,
	"Non-Sense": false,
	"Cuzinho": false
}

@onready var pack_panels = {
	"Classico": $MarginContainer/ScrollContainer/HBoxContainer/Panel,
	"Non-Sense": $MarginContainer/ScrollContainer/HBoxContainer/Panel2,
	"Cuzinho": $MarginContainer/ScrollContainer/HBoxContainer/Panel3,
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
	
func _on_ClassicPack_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Panel clicked!")
	_on_pack_panel_pressed("Classico")
	
func _on_NonSensePack_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		print("Panel clicked!")
	_on_pack_panel_pressed("Non-Sense")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
