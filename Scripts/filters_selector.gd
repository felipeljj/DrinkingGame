extends Control

var pack_state = {}
var selected_mode: String = "normal"
var team_config = {}
var selected_filters: Array[String] = []

@onready var title_label = $VBoxContainer/Title
@onready var voltar_button = $VBoxContainer/ButtonsContainer/VoltarButton
@onready var jogar_button = $VBoxContainer/ButtonsContainer/JogarButton

func _ready():
	# Atualizar textos
	_update_ui_texts()
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)
	
	# Adicionar hover effects
	UIManager.add_button_hover_effect(voltar_button)
	UIManager.add_button_hover_effect(jogar_button)
	
	# Animar entrada
	_animate_entrance()
	
	UIManager.safe_vibrate(50)

func _animate_entrance():
	# Animar título
	title_label.modulate.a = 0.0
	title_label.position.y -= 30
	var title_tween = title_label.create_tween().set_parallel(true)
	title_tween.tween_property(title_label, "modulate:a", 1.0, 0.4)
	title_tween.tween_property(title_label, "position:y", title_label.position.y + 30, 0.4).set_trans(Tween.TRANS_BACK)
	
	# Animar tutorial cards
	var tutorial_container = $VBoxContainer/TutorialContainer
	if tutorial_container:
		var delay = 0.15
		for child in tutorial_container.get_children():
			child.modulate.a = 0.0
			child.position.x -= 60
			
			var tween = child.create_tween().set_parallel(true)
			tween.tween_property(child, "modulate:a", 1.0, 0.35).set_delay(delay)
			tween.tween_property(child, "position:x", child.position.x + 60, 0.35).set_delay(delay).set_trans(Tween.TRANS_BACK)
			delay += 0.12

func _update_ui_texts():
	if title_label:
		title_label.text = LocalizationManager.translate("tutorial_title", "COMO JOGAR")
	if voltar_button:
		voltar_button.text = "← " + LocalizationManager.translate("filters_back", "Voltar")
	if jogar_button:
		jogar_button.text = LocalizationManager.translate("filters_play", "Jogar") + " →"
	
	# Atualizar textos do tutorial de swipe
	var tutorial_container = $VBoxContainer/TutorialContainer
	if tutorial_container:
		# Swipe esquerda (nova carta) - agora é o primeiro card na UI
		if tutorial_container.has_node("SwipeRightCard/MarginContainer/HBox/VBox/Title"):
			tutorial_container.get_node("SwipeRightCard/MarginContainer/HBox/VBox/Title").text = LocalizationManager.translate("tutorial_swipe_left_title", "Deslizar para ESQUERDA")
		if tutorial_container.has_node("SwipeRightCard/MarginContainer/HBox/VBox/Desc"):
			tutorial_container.get_node("SwipeRightCard/MarginContainer/HBox/VBox/Desc").text = LocalizationManager.translate("tutorial_swipe_left_desc", "Avança para uma NOVA carta")
		
		# Swipe direita (voltar) - agora é o segundo card na UI
		if tutorial_container.has_node("SwipeLeftCard/MarginContainer/HBox/VBox/Title"):
			tutorial_container.get_node("SwipeLeftCard/MarginContainer/HBox/VBox/Title").text = LocalizationManager.translate("tutorial_swipe_right_title", "Deslizar para DIREITA")
		if tutorial_container.has_node("SwipeLeftCard/MarginContainer/HBox/VBox/Desc"):
			tutorial_container.get_node("SwipeLeftCard/MarginContainer/HBox/VBox/Desc").text = LocalizationManager.translate("tutorial_swipe_right_desc", "Volta para a carta ANTERIOR")
		
		# Dica
		if tutorial_container.has_node("TipCard/MarginContainer/HBox/VBox/Desc"):
			tutorial_container.get_node("TipCard/MarginContainer/HBox/VBox/Desc").text = LocalizationManager.translate("tutorial_tip", "Você também pode usar o botão para avançar")

func _on_voltar_pressed():
	UIManager.change_scene_with_fade("res://Scenes/mode_selector.tscn")

func _on_jogar_pressed():
	# Carregar cena de cartas
	var packed_scene = load("res://Scenes/generate_cards.tscn")
	var next_scene = packed_scene.instantiate()
	
	# Passar configurações
	next_scene.pack_state = pack_state
	next_scene.set("game_mode", selected_mode)
	next_scene.set("team_config", team_config)
	next_scene.set("active_filters", selected_filters)
	
	# Mudar cena
	var current = get_tree().current_scene
	get_tree().root.add_child(next_scene)
	get_tree().set_current_scene(next_scene)
	if current and is_instance_valid(current):
		current.queue_free()
