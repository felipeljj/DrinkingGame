extends Control

var pack_state = {}
var selected_mode: String = "normal"

# Configurações dos times
var team_config = {
	"enabled": false,
	"num_teams": 2,
	"team_names": ["Time A", "Time B"],
	"team_colors": [Color("#FF5733"), Color("#3357FF")]
}

func _ready():
	var normal_btn = $VBoxContainer/ModeGrid/Normal
	var times_btn = $VBoxContainer/ModeGrid/Times
	var back_btn = $VBoxContainer/Voltar
	
	# Atualizar textos traduzidos
	_update_ui_texts()
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)
	
	# Hover apenas para botões ativos
	UIManager.add_button_hover_effect(normal_btn)
	UIManager.add_button_hover_effect(back_btn)
	
	# Desativar temporariamente o modo Times
	times_btn.disabled = true
	times_btn.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN
	
	# Aplicar estilos aos botões
	_apply_button_styles()

func _update_ui_texts():
	if has_node("VBoxContainer/Title"):
		$VBoxContainer/Title.text = LocalizationManager.translate("mode_selector_title", "Escolha o Modo")
	if has_node("VBoxContainer/Subtitle"):
		$VBoxContainer/Subtitle.text = LocalizationManager.translate("mode_selector_subtitle", "Como vocês querem jogar?")
	
	var normal_btn = $VBoxContainer/ModeGrid/Normal
	var times_btn = $VBoxContainer/ModeGrid/Times
	var back_btn = $VBoxContainer/Voltar
	
	if normal_btn:
		normal_btn.text = "🎮 " + LocalizationManager.translate("mode_normal", "Normal")
		if normal_btn.has_node("Description"):
			normal_btn.get_node("Description").text = LocalizationManager.translate("mode_normal_description", "Jogue com as cartas selecionadas.")
	
	if times_btn:
		times_btn.text = LocalizationManager.translate("mode_times", "Times")
		if times_btn.has_node("Description"):
			times_btn.get_node("Description").text = LocalizationManager.translate("mode_times_description", "Divida-se em times e compita!")
	
	if back_btn:
		back_btn.text = LocalizationManager.translate("mode_back", "Voltar")

func _apply_button_styles():
	var normal_btn = $VBoxContainer/ModeGrid/Normal
	var times_btn = $VBoxContainer/ModeGrid/Times
	
	# Estilo botão Normal
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.2, 0.6, 0.9, 1)
	normal_style.set_corner_radius_all(25)
	normal_style.shadow_size = 15
	normal_style.shadow_color = Color(0, 0, 0, 0.4)
	normal_btn.add_theme_stylebox_override("normal", normal_style)
	normal_btn.add_theme_stylebox_override("hover", normal_style)
	normal_btn.add_theme_stylebox_override("pressed", normal_style)
	
	# Estilo botão Times
	var times_style = StyleBoxFlat.new()
	times_style.bg_color = Color(0.5, 0.5, 0.5, 0.6)
	times_style.set_corner_radius_all(25)
	times_style.shadow_size = 10
	times_style.shadow_color = Color(0, 0, 0, 0.2)
	times_btn.add_theme_stylebox_override("normal", times_style)
	times_btn.add_theme_stylebox_override("hover", times_style)
	times_btn.add_theme_stylebox_override("pressed", times_style)
	times_btn.add_theme_stylebox_override("disabled", times_style)
	times_btn.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2, 1))
	times_btn.add_theme_color_override("font_color_disabled", Color(0.2, 0.2, 0.2, 0.8))

func _on_normal_pressed() -> void:
	selected_mode = "normal"
	_show_filters()

func _on_times_pressed() -> void:
	selected_mode = "times"
	_show_team_config()

func _on_voltar_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/pack_selector.tscn")

func _show_filters():
	# Carregar tela de filtros
	var scene = load("res://Scenes/filters_selector.tscn")
	if not scene:
		# Fallback: iniciar jogo direto
		_start_game()
		return
	
	var filters_scene = scene.instantiate()
	filters_scene.pack_state = pack_state
	filters_scene.selected_mode = selected_mode
	filters_scene.team_config = team_config
	
	var current = get_tree().current_scene
	get_tree().root.add_child(filters_scene)
	get_tree().set_current_scene(filters_scene)
	if current and is_instance_valid(current):
		current.queue_free()

func _start_game():
	# Carregar cena de cartas
	var packed_scene = load("res://Scenes/generate_cards.tscn")
	var next_scene = packed_scene.instantiate()
	
	# Passar configurações
	next_scene.pack_state = pack_state
	next_scene.set("game_mode", selected_mode)
	next_scene.set("team_config", team_config)
	
	# Mudar cena
	var current = get_tree().current_scene
	get_tree().root.add_child(next_scene)
	get_tree().set_current_scene(next_scene)
	if current and is_instance_valid(current):
		current.queue_free()

func _show_team_config():
	var scene = load("res://Scenes/team_config.tscn")
	if not scene:
		# fallback: inicia com padrão
		team_config.enabled = true
		_start_game()
		return
	var cfg = scene.instantiate()
	cfg.set("pack_state", pack_state)
	get_tree().root.add_child(cfg)
	get_tree().current_scene.queue_free()
