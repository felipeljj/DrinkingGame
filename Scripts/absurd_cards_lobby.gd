extends Control

@onready var name_input = $VBox/NameContainer/NameInput
@onready var buttons_container = $VBox/ButtonsContainer
@onready var join_container = $VBox/JoinContainer
@onready var code_input = $VBox/JoinContainer/CodeInput
@onready var room_code_panel = $VBox/RoomCodeDisplay
@onready var room_code_value = $VBox/RoomCodeDisplay/VBox/CodeValue
@onready var status_label = $VBox/StatusLabel
@onready var players_panel = $VBox/PlayersPanel
@onready var players_list = $VBox/PlayersPanel/VBox/PlayersList
@onready var players_title = $VBox/PlayersPanel/VBox/PlayersTitle
@onready var settings_container = $VBox/SettingsContainer
@onready var points_input = $VBox/SettingsContainer/PointsInput
@onready var bot_container = $VBox/BotContainer
@onready var add_bot_btn = $VBox/BotContainer/AddBotBtn
@onready var remove_bot_btn = $VBox/BotContainer/RemoveBotBtn
@onready var bot_count_label = $VBox/BotContainer/BotCountLabel
@onready var start_game_btn = $VBox/StartGameBtn
@onready var back_btn = $VBox/BackBtn
@onready var create_room_btn = $VBox/ButtonsContainer/CreateRoomBtn
@onready var join_room_btn = $VBox/ButtonsContainer/JoinRoomBtn
@onready var connect_btn = $VBox/JoinContainer/ConnectBtn
@onready var title_label = $VBox/Title
@onready var subtitle_label = $VBox/Subtitle
@onready var name_label = $VBox/NameContainer/Label

# Config Popup
@onready var config_popup = $ConfigPopup
@onready var config_panel = $ConfigPopup/ConfigPanel
@onready var online_mode_btn = $ConfigPopup/ConfigPanel/VBox/ModeContainer/OnlineModeBtn
@onready var local_mode_btn = $ConfigPopup/ConfigPanel/VBox/ModeContainer/LocalModeBtn
@onready var order_label = $ConfigPopup/ConfigPanel/VBox/OrderLabel
@onready var order_list_scroll = $ConfigPopup/ConfigPanel/VBox/OrderListScroll
@onready var order_list = $ConfigPopup/ConfigPanel/VBox/OrderListScroll/OrderList
@onready var confirm_start_btn = $ConfigPopup/ConfigPanel/VBox/ConfirmStartBtn

var is_in_room = false
var is_local_mode = false
var ordered_players: Array = []
var selected_pack: String = "classico"

func _ready():
	# Conectar sinais do MultiplayerManager
	MultiplayerManager.room_code_generated.connect(_on_room_code_generated)
	MultiplayerManager.player_list_updated.connect(_on_player_list_updated)
	MultiplayerManager.connection_succeeded.connect(_on_connection_succeeded)
	MultiplayerManager.connection_failed.connect(_on_connection_failed)
	MultiplayerManager.server_disconnected.connect(_on_server_disconnected)
	MultiplayerManager.game_started.connect(_on_game_started)
	
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)
	
	# Aplicar estilos premium
	_apply_styles()
	
	# Atualizar textos
	_update_ui_texts()
	
	# Adicionar partículas
	ParticlesManager.create_bubble_particles(self)
	
	# Nome padrão
	name_input.text = LocalizationManager.translate("default_player_name") + str(randi() % 1000)
	
	# Modo LOCAL: Esconder botão de entrar em sala (não faz sentido sem rede)
	if join_room_btn:
		join_room_btn.visible = false
	
	# Hover effects
	UIManager.add_button_hover_effect(create_room_btn)
	UIManager.add_button_hover_effect(start_game_btn)
	UIManager.add_button_hover_effect(back_btn)

func _update_ui_texts():
	# UI Principal
	if title_label:
		title_label.text = LocalizationManager.translate("lobby_absurd_title", "CARTAS CONTRA OS BONS COSTUMES")
	if subtitle_label:
		subtitle_label.text = LocalizationManager.translate("lobby_absurd_subtitle_local", "Jogo local • 3 a 15 jogadores • Passe o celular!")
	if name_label:
		name_label.text = LocalizationManager.translate("lobby_your_name", "Seu nome:")
		
	# Botões
	if create_room_btn:
		create_room_btn.text = LocalizationManager.translate("lobby_new_game", "Novo Jogo")
	if start_game_btn:
		start_game_btn.text = LocalizationManager.translate("lobby_start_game", "Iniciar Jogo")
	
	# Atualizar placeholder se vazio
	if name_input and name_input.text.begins_with("Player"):
		# Se for o default antigo, tenta traduzir. Mas cuidado pra não sobrescrever input do user.
		# Melhor só garantir que labels estáticos estão certos.
		pass
		
	# Textos variáveis como BackBtn são atualizados em _enter_room_mode/_exit_room_mode,
	# mas aqui podemos forçar o estado atual
	if is_in_room:
		back_btn.text = LocalizationManager.translate("lobby_leave_room", "Sair da Sala")
	else:
		back_btn.text = LocalizationManager.translate("lobby_back", "Voltar")
		
	# Config Popup
	if online_mode_btn:
		online_mode_btn.text = LocalizationManager.translate("config_mode_online", "ONLINE")
	if local_mode_btn:
		local_mode_btn.text = LocalizationManager.translate("config_mode_local", "LOCAL")
	if order_label:
		order_label.text = LocalizationManager.translate("config_order_label_local", "Ordem de jogo (quem começa primeiro):")
	if confirm_start_btn:
		confirm_start_btn.text = LocalizationManager.translate("config_confirm_start", "COMEÇAR JOGO")

func _apply_styles():
	# Estilo dos botões principais (branco)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(1, 1, 1, 1)
	btn_style.set_corner_radius_all(20)
	
	for btn in [create_room_btn, join_room_btn]:
		if btn:
			btn.add_theme_stylebox_override("normal", btn_style)
			btn.add_theme_stylebox_override("hover", btn_style)
			btn.add_theme_stylebox_override("pressed", btn_style)
			btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
			btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
			btn.add_theme_color_override("font_pressed_color", Color(0.3, 0.3, 0.3, 1))
	
	# Estilo do botão conectar
	if connect_btn:
		var connect_style = StyleBoxFlat.new()
		connect_style.bg_color = Color(0.2, 0.8, 0.3, 1)
		connect_style.set_corner_radius_all(15)
		connect_btn.add_theme_stylebox_override("normal", connect_style)
		connect_btn.add_theme_stylebox_override("hover", connect_style)
		connect_btn.add_theme_stylebox_override("pressed", connect_style)
		connect_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		connect_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	
	# Estilo do botão iniciar (verde)
	if start_game_btn:
		var start_style = StyleBoxFlat.new()
		start_style.bg_color = Color(0.2, 0.8, 0.3, 1)
		start_style.set_corner_radius_all(20)
		start_game_btn.add_theme_stylebox_override("normal", start_style)
		start_game_btn.add_theme_stylebox_override("hover", start_style)
		start_game_btn.add_theme_stylebox_override("pressed", start_style)
		start_game_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		start_game_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))
	
	# Estilo do painel de jogadores
	if players_panel:
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = Color(0.08, 0.08, 0.08, 1)
		panel_style.set_corner_radius_all(20)
		panel_style.border_width_left = 2
		panel_style.border_width_right = 2
		panel_style.border_width_top = 2
		panel_style.border_width_bottom = 2
		panel_style.border_color = Color(0.3, 0.3, 0.3, 1)
		players_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Estilo do painel de código
	if room_code_panel:
		var code_style = StyleBoxFlat.new()
		code_style.bg_color = Color(0.15, 0.15, 0.15, 1)
		code_style.set_corner_radius_all(15)
		code_style.border_width_left = 3
		code_style.border_width_right = 3
		code_style.border_width_top = 3
		code_style.border_width_bottom = 3
		code_style.border_color = Color(1, 1, 1, 0.5)
		room_code_panel.add_theme_stylebox_override("panel", code_style)
	
	# Estilo do input de nome
	if name_input:
		var input_style = StyleBoxFlat.new()
		input_style.bg_color = Color(0.15, 0.15, 0.15, 1)
		input_style.set_corner_radius_all(12)
		input_style.border_width_left = 2
		input_style.border_width_right = 2
		input_style.border_width_top = 2
		input_style.border_width_bottom = 2
		input_style.border_color = Color(0.4, 0.4, 0.4, 1)
		name_input.add_theme_stylebox_override("normal", input_style)
	
	# Estilo do input de código
	if code_input:
		var code_input_style = StyleBoxFlat.new()
		code_input_style.bg_color = Color(0.1, 0.1, 0.1, 1)
		code_input_style.set_corner_radius_all(15)
		code_input_style.border_width_left = 3
		code_input_style.border_width_right = 3
		code_input_style.border_width_top = 3
		code_input_style.border_width_bottom = 3
		code_input_style.border_color = Color(1, 1, 1, 0.6)
		code_input.add_theme_stylebox_override("normal", code_input_style)
	
	# ============================================
	# ESTILOS DO CONFIG POPUP
	# ============================================
	
	# Painel do Config (estilo premium escuro com borda)
	if config_panel:
		var config_style = StyleBoxFlat.new()
		config_style.bg_color = Color(0.06, 0.06, 0.06, 0.98)
		config_style.set_corner_radius_all(30)
		config_style.border_width_left = 3
		config_style.border_width_right = 3
		config_style.border_width_top = 3
		config_style.border_width_bottom = 3
		config_style.border_color = Color(1, 0.85, 0.3, 0.8)  # Dourado
		config_style.shadow_size = 40
		config_style.shadow_color = Color(0, 0, 0, 0.7)
		config_panel.add_theme_stylebox_override("panel", config_style)
	
	# Estilo do botão ONLINE (toggle)
	if online_mode_btn:
		var online_style = StyleBoxFlat.new()
		online_style.bg_color = Color(0.15, 0.15, 0.15, 1)
		online_style.set_corner_radius_all(15)
		online_style.border_width_left = 2
		online_style.border_width_right = 2
		online_style.border_width_top = 2
		online_style.border_width_bottom = 2
		online_style.border_color = Color(0.4, 0.4, 0.4, 1)
		
		var online_pressed_style = StyleBoxFlat.new()
		online_pressed_style.bg_color = Color(0.2, 0.6, 0.9, 1)  # Azul
		online_pressed_style.set_corner_radius_all(15)
		online_pressed_style.shadow_size = 15
		online_pressed_style.shadow_color = Color(0.2, 0.6, 0.9, 0.5)
		
		online_mode_btn.add_theme_stylebox_override("normal", online_style)
		online_mode_btn.add_theme_stylebox_override("hover", online_style)
		online_mode_btn.add_theme_stylebox_override("pressed", online_pressed_style)
		online_mode_btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
		online_mode_btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))
	
	# Estilo do botão LOCAL (toggle)
	if local_mode_btn:
		var local_style = StyleBoxFlat.new()
		local_style.bg_color = Color(0.15, 0.15, 0.15, 1)
		local_style.set_corner_radius_all(15)
		local_style.border_width_left = 2
		local_style.border_width_right = 2
		local_style.border_width_top = 2
		local_style.border_width_bottom = 2
		local_style.border_color = Color(0.4, 0.4, 0.4, 1)
		
		var local_pressed_style = StyleBoxFlat.new()
		local_pressed_style.bg_color = Color(0.9, 0.5, 0.2, 1)  # Laranja
		local_pressed_style.set_corner_radius_all(15)
		local_pressed_style.shadow_size = 15
		local_pressed_style.shadow_color = Color(0.9, 0.5, 0.2, 0.5)
		
		local_mode_btn.add_theme_stylebox_override("normal", local_style)
		local_mode_btn.add_theme_stylebox_override("hover", local_style)
		local_mode_btn.add_theme_stylebox_override("pressed", local_pressed_style)
		local_mode_btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
		local_mode_btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1, 1))
	
	# Estilo do botão COMEÇAR (verde vibrante)
	if confirm_start_btn:
		var confirm_style = StyleBoxFlat.new()
		confirm_style.bg_color = Color(0.2, 0.8, 0.3, 1)
		confirm_style.set_corner_radius_all(20)
		confirm_style.shadow_size = 20
		confirm_style.shadow_color = Color(0.2, 0.8, 0.3, 0.4)
		
		var confirm_hover = StyleBoxFlat.new()
		confirm_hover.bg_color = Color(0.25, 0.9, 0.35, 1)
		confirm_hover.set_corner_radius_all(20)
		confirm_hover.shadow_size = 25
		confirm_hover.shadow_color = Color(0.25, 0.9, 0.35, 0.5)
		
		confirm_start_btn.add_theme_stylebox_override("normal", confirm_style)
		confirm_start_btn.add_theme_stylebox_override("hover", confirm_hover)
		confirm_start_btn.add_theme_stylebox_override("pressed", confirm_style)
		confirm_start_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
		confirm_start_btn.add_theme_color_override("font_hover_color", Color(0, 0, 0, 1))

func _on_create_room_pressed():
	var player_name = name_input.text.strip_edges()
	if player_name.is_empty():
		_show_status(LocalizationManager.translate("lobby_enter_name"), Color.RED)
		UIManager.safe_vibrate(100)
		return
	
	MultiplayerManager.game_settings["pending_player_name"] = player_name
	
	# Bypass selector - direct creation
	UIManager.safe_vibrate(50)
	_show_status(LocalizationManager.translate("lobby_creating_room"), Color.YELLOW)
	
	var code = MultiplayerManager.create_room(player_name)
	if not code.is_empty():
		_enter_room_mode(true)
		room_code_value.text = code
		_show_status(LocalizationManager.translate("lobby_room_created"), Color.GREEN)
	else:
		_show_status(LocalizationManager.translate("lobby_create_error"), Color.RED)

func _on_join_room_pressed():
	UIManager.safe_vibrate(50)
	join_container.visible = true
	buttons_container.visible = false
	code_input.grab_focus()

func _on_connect_pressed():
	var player_name = name_input.text.strip_edges()
	if player_name.is_empty():
		_show_status(LocalizationManager.translate("lobby_enter_name"), Color.RED)
		UIManager.safe_vibrate(100)
		return
	
	var code = code_input.text.strip_edges().to_upper()
	if code.length() != 6:
		_show_status(LocalizationManager.translate("lobby_code_length_error"), Color.RED)
		UIManager.safe_vibrate(100)
		return
	
	_show_status(LocalizationManager.translate("lobby_searching_room") % code, Color.YELLOW)
	UIManager.safe_vibrate(50)
	
	var success = await MultiplayerManager.join_room(code, player_name)
	if not success:
		_show_status(LocalizationManager.translate("lobby_room_not_found"), Color.RED)
		UIManager.safe_vibrate(100)

func _on_start_game_pressed():
	var players = MultiplayerManager.get_player_list()
	if players.size() < MultiplayerManager.MIN_PLAYERS:
		_show_status(LocalizationManager.translate("lobby_min_players_error") % MultiplayerManager.MIN_PLAYERS, Color.RED)
		UIManager.safe_vibrate(100)
		return
	
	UIManager.safe_vibrate(50)
	
	# Abrir popup de configuração
	_open_config_popup()

func _on_back_pressed():
	UIManager.safe_vibrate(30)
	
	if is_in_room:
		MultiplayerManager.leave_room()
		_exit_room_mode()
	elif join_container.visible:
		join_container.visible = false
		buttons_container.visible = true
	else:
		UIManager.change_scene_with_fade("res://Scenes/game_hub.tscn")

func _enter_room_mode(is_host: bool):
	is_in_room = true
	buttons_container.visible = false
	join_container.visible = false
	players_panel.visible = true
	name_input.editable = false
	
	if is_host:
		# Modo LOCAL: não mostrar código da sala (não faz sentido sem rede)
		room_code_panel.visible = false
		settings_container.visible = true
		bot_container.visible = true  # Mostrar controles de bot para o host
		start_game_btn.visible = true
	
	back_btn.text = LocalizationManager.translate("lobby_leave_room")

func _exit_room_mode():
	is_in_room = false
	buttons_container.visible = true
	join_container.visible = false
	players_panel.visible = false
	room_code_panel.visible = false
	settings_container.visible = false
	bot_container.visible = false
	start_game_btn.visible = false
	name_input.editable = true
	back_btn.text = LocalizationManager.translate("lobby_back")
	_show_status("", Color.WHITE)
	
	# Limpar bots ao sair
	MultiplayerManager.clear_bots()
	_update_bot_count()

func _show_status(text: String, color: Color):
	status_label.text = text
	status_label.modulate = color
	
	# Animação de pulse
	if text != "":
		var tween = status_label.create_tween()
		tween.tween_property(status_label, "scale", Vector2(1.05, 1.05), 0.1)
		tween.tween_property(status_label, "scale", Vector2.ONE, 0.1)

func _update_players_list(players: Array):
	# Limpar lista
	for child in players_list.get_children():
		child.queue_free()
	
	# Adicionar jogadores com estilo
	for player in players:
		var container = HBoxContainer.new()
		container.alignment = BoxContainer.ALIGNMENT_CENTER
		container.add_theme_constant_override("separation", 10)
		
		var label = Label.new()
		var prefix = "[HOST] " if player.get("is_host", false) else "[P] "
		label.text = prefix + player.get("name", "???")
		label.add_theme_font_size_override("font_size", 30)
		
		if player.get("is_host", false):
			label.modulate = Color(1, 0.85, 0.3, 1)
		
		container.add_child(label)
		players_list.add_child(container)
	
	# Atualizar título
	players_title.text = LocalizationManager.translate("lobby_players_title") % [players.size(), 15]
	
	# Habilitar/desabilitar botão de iniciar
	if MultiplayerManager.is_host:
		start_game_btn.disabled = players.size() < MultiplayerManager.MIN_PLAYERS
		if players.size() < MultiplayerManager.MIN_PLAYERS:
			_show_status(LocalizationManager.translate("lobby_waiting_players"), Color.YELLOW)
		else:
			_show_status(LocalizationManager.translate("lobby_ready"), Color.GREEN)

# ============================================
# CALLBACKS DO MULTIPLAYER MANAGER
# ============================================

func _on_room_code_generated(code: String):
	room_code_value.text = code
	_show_status(LocalizationManager.translate("lobby_code_share"), Color.GREEN)

func _on_player_list_updated(players: Array):
	_update_players_list(players)

func _on_connection_succeeded():
	_enter_room_mode(false)
	_show_status(LocalizationManager.translate("lobby_connected"), Color.GREEN)

func _on_connection_failed():
	_show_status(LocalizationManager.translate("lobby_connection_failed"), Color.RED)
	UIManager.safe_vibrate(100)

func _on_server_disconnected():
	_exit_room_mode()
	_show_status(LocalizationManager.translate("lobby_host_disconnected"), Color.RED)
	UIManager.safe_vibrate(100)

func _on_game_started():
	# Ir para a tela do jogo
	var game_scene = load("res://Scenes/absurd_cards_game.tscn")
	var game = game_scene.instantiate()
	
	var current = get_tree().current_scene
	get_tree().root.add_child(game)
	get_tree().set_current_scene(game)
	if current and is_instance_valid(current):
		current.queue_free()

# ============================================
# FUNÇÕES DE BOTS
# ============================================

func _on_add_bot_pressed():
	UIManager.safe_vibrate(30)
	
	if MultiplayerManager.add_bot():
		_update_bot_count()
		_show_status(LocalizationManager.translate("lobby_bot_added"), Color.GREEN)
	else:
		_show_status(LocalizationManager.translate("lobby_max_players_error"), Color.RED)

func _on_remove_bot_pressed():
	UIManager.safe_vibrate(30)
	
	if MultiplayerManager.remove_bot():
		_update_bot_count()
		_show_status(LocalizationManager.translate("lobby_bot_removed"), Color.YELLOW)
	else:
		_show_status(LocalizationManager.translate("lobby_no_bot_remove"), Color.RED)

func _update_bot_count():
	if bot_count_label:
		bot_count_label.text = str(MultiplayerManager.get_bots_count())

# ============================================
# CONFIG POPUP
# ============================================

func _open_config_popup():
	config_popup.visible = true
	
	# Modo LOCAL é o único disponível agora (online desabilitado)
	is_local_mode = true
	
	# Esconder seletor de modo (só temos LOCAL)
	var mode_container = config_panel.get_node_or_null("VBox/ModeContainer")
	if mode_container:
		mode_container.visible = false
	
	# Sempre mostrar lista de ordenação no modo local
	_update_order_list_visibility()
	
	# Popular lista de jogadores
	_populate_order_list()
	
	# Animação de entrada
	config_panel.scale = Vector2(0.8, 0.8)
	config_panel.modulate.a = 0
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(config_panel, "scale", Vector2.ONE, 0.3)
	tween.tween_property(config_panel, "modulate:a", 1.0, 0.3)

func _close_config_popup():
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(config_panel, "scale", Vector2(0.8, 0.8), 0.2)
	tween.tween_property(config_panel, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	config_popup.visible = false

func _on_online_mode_pressed():
	is_local_mode = false
	_update_order_list_visibility()
	UIManager.safe_vibrate(30)

func _on_local_mode_pressed():
	is_local_mode = true
	_update_order_list_visibility()
	UIManager.safe_vibrate(30)

func _update_order_list_visibility():
	# Modo LOCAL é o único, sempre mostrar ordenação
	order_label.visible = true
	order_list_scroll.visible = true

func _populate_order_list():
	# Limpar lista
	for child in order_list.get_children():
		child.queue_free()
	
	# Pegar jogadores
	ordered_players = MultiplayerManager.get_player_list().duplicate()
	
	# Criar itens arrastáveis
	for i in range(ordered_players.size()):
		var player = ordered_players[i]
		var item = _create_draggable_player_item(player, i)
		order_list.add_child(item)

func _create_draggable_player_item(player: Dictionary, index: int) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(0, 80)
	
	# Estilo
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15, 1)
	style.set_corner_radius_all(12)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.4, 1)
	panel.add_theme_stylebox_override("panel", style)
	
	# Container
	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 20
	hbox.offset_right = -20
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 15)
	panel.add_child(hbox)
	
	# Ícone de arraste
	var drag_icon = Label.new()
	drag_icon.text = "="
	drag_icon.add_theme_font_size_override("font_size", 32)
	hbox.add_child(drag_icon)
	
	# Número da ordem
	var num_label = Label.new()
	num_label.text = str(index + 1) + "."
	num_label.add_theme_font_size_override("font_size", 28)
	num_label.add_theme_color_override("font_color", Color.YELLOW)
	hbox.add_child(num_label)
	
	# Nome do jogador
	var name_label = Label.new()
	var prefix = "[HOST] " if player.get("is_host", false) else ""
	prefix += "[BOT] " if player.get("is_bot", false) else ""
	name_label.text = prefix + player.get("name", "???")
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(name_label)
	
	# Guardar referência ao jogador
	panel.set_meta("player_data", player)
	panel.set_meta("player_index", index)
	
	# Botões de mover (simplificado sem drag real)
	var up_btn = Button.new()
	up_btn.text = "^"
	up_btn.custom_minimum_size = Vector2(60, 60)
	up_btn.pressed.connect(_on_move_player_up.bind(panel))
	hbox.add_child(up_btn)
	
	var down_btn = Button.new()
	down_btn.text = "v"
	down_btn.custom_minimum_size = Vector2(60, 60)
	down_btn.pressed.connect(_on_move_player_down.bind(panel))
	hbox.add_child(down_btn)
	
	return panel

func _on_move_player_up(panel: Panel):
	var idx = panel.get_index()
	if idx > 0:
		order_list.move_child(panel, idx - 1)
		_update_order_numbers()
		UIManager.safe_vibrate(20)

func _on_move_player_down(panel: Panel):
	var idx = panel.get_index()
	if idx < order_list.get_child_count() - 1:
		order_list.move_child(panel, idx + 1)
		_update_order_numbers()
		UIManager.safe_vibrate(20)

func _update_order_numbers():
	var idx = 1
	for child in order_list.get_children():
		if child is Panel:
			var hbox = child.get_child(0)
			if hbox and hbox.get_child_count() > 1:
				var num_label = hbox.get_child(1)
				if num_label is Label:
					num_label.text = str(idx) + "."
		idx += 1

func _on_confirm_start_pressed():
	UIManager.safe_vibrate(50)
	
	# Coletar ordem final
	var final_order = []
	for child in order_list.get_children():
		if child is Panel and child.has_meta("player_data"):
			final_order.append(child.get_meta("player_data"))
	
	# Salvar configurações
	MultiplayerManager.set_game_settings({
		"points_to_win": int(points_input.value),
		"is_local_mode": is_local_mode,
		"players_order": final_order if is_local_mode else []
	})
	
	_close_config_popup()
	await get_tree().create_timer(0.3).timeout
	MultiplayerManager.start_game()

func _on_cancel_config_pressed():
	UIManager.safe_vibrate(30)
	_close_config_popup()

# ============================================
# SELETOR DE PACKS
# ============================================

func _show_pack_selector(player_name: String):
	# Criar overlay escuro
	var overlay = ColorRect.new()
	overlay.name = "PackSelectorOverlay"
	overlay.color = Color(0, 0, 0, 0.9)
	overlay.z_index = 499
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	
	# Criar popup
	var viewport_size = get_viewport_rect().size
	var popup = Panel.new()
	popup.name = "PackSelectorPopup"
	popup.z_index = 500
	
	# Estilo do popup
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 1.0)
	style.set_corner_radius_all(25)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(1, 1, 1, 0.8)
	popup.add_theme_stylebox_override("panel", style)
	
	# Tamanho
	var popup_width = min(viewport_size.x * 0.9, 900)
	var popup_height = min(viewport_size.y * 0.85, 1000)
	popup.size = Vector2(popup_width, popup_height)
	popup.position = Vector2((viewport_size.x - popup_width) / 2, (viewport_size.y - popup_height) / 2)
	
	add_child(popup)
	
	# Container vertical
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 30
	vbox.offset_top = 25
	vbox.offset_right = -30
	vbox.offset_bottom = -25
	vbox.add_theme_constant_override("separation", 20)
	popup.add_child(vbox)
	
	# Título
	var title = Label.new()
	title.text = LocalizationManager.translate("pack_selector_title_caps")
	title.add_theme_font_size_override("font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Container de packs (horizontal)
	var packs_container = HBoxContainer.new()
	packs_container.alignment = BoxContainer.ALIGNMENT_CENTER
	packs_container.add_theme_constant_override("separation", 30)
	packs_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(packs_container)
	
	# Criar cards para cada pack
	var packs = AbsurdCardsData.get_packs_info()
	for pack_info in packs:
		var pack_card = _create_pack_card(pack_info, overlay, popup, player_name)
		packs_container.add_child(pack_card)
	
	# Botão Cancelar
	var cancel_btn = Button.new()
	cancel_btn.text = LocalizationManager.translate("lobby_back")
	cancel_btn.add_theme_font_size_override("font_size", 32)
	cancel_btn.custom_minimum_size = Vector2(0, 60)
	cancel_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cancel_btn.flat = true
	cancel_btn.pressed.connect(func():
		UIManager.safe_vibrate(30)
		overlay.queue_free()
		popup.queue_free()
	)
	vbox.add_child(cancel_btn)
	
	# Animação de entrada
	overlay.modulate.a = 0.0
	popup.modulate.a = 0.0
	popup.scale = Vector2(0.9, 0.9)
	popup.pivot_offset = popup.size / 2
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(overlay, "modulate:a", 1.0, 0.3)
	tween.tween_property(popup, "modulate:a", 1.0, 0.3)
	tween.tween_property(popup, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _create_pack_card(pack_info: Dictionary, overlay: ColorRect, popup: Panel, player_name: String) -> Panel:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(350, 450)
	
	# Estilo do card
	var card_style = StyleBoxFlat.new()
	if pack_info.available:
		card_style.bg_color = Color(0.1, 0.1, 0.1, 1)
		card_style.border_color = Color(1, 0.85, 0.3, 0.8)
	else:
		card_style.bg_color = Color(0.08, 0.08, 0.08, 0.7)
		card_style.border_color = Color(0.4, 0.4, 0.4, 0.5)
	card_style.set_corner_radius_all(20)
	card_style.border_width_left = 3
	card_style.border_width_right = 3
	card_style.border_width_top = 3
	card_style.border_width_bottom = 3
	card.add_theme_stylebox_override("panel", card_style)
	
	# VBox interno
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_top = 25
	vbox.offset_right = -20
	vbox.offset_bottom = -25
	vbox.add_theme_constant_override("separation", 15)
	card.add_child(vbox)
	
	# Nome do pack (Já deve vir localizado do AbsurdCardsData ou chaves) 
	# Assumindo que o AbsurdCardsData retorna nomes estáticos, podemos precisar traduzir aqui se forem chaves
	# Se pack_info.name for "Clássico", e tiver chave "pack_classic", melhor usar a chave.
	# Verificando AbsurdCardsData... por enquanto vamos assumir que o nome é texto.
	# MAS o ideal é traduzir.
	var name_label = Label.new()
	var pack_name_key = "pack_" + pack_info.id
	name_label.text = LocalizationManager.translate(pack_name_key, pack_info.name)
	name_label.add_theme_font_size_override("font_size", 40)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if not pack_info.available:
		name_label.modulate = Color(0.5, 0.5, 0.5, 1)
	vbox.add_child(name_label)
	
	# Descrição
	var desc_label = Label.new()
	var pack_desc_key = "pack_" + pack_info.id + "_description"
	desc_label.text = LocalizationManager.translate(pack_desc_key, pack_info.description)
	desc_label.add_theme_font_size_override("font_size", 24)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	# Contagem de cartas
	var count_label = Label.new()
	if pack_info.available:
		count_label.text = str(pack_info.black_count) + " " + LocalizationManager.translate("pack_black_cards") + "\n" + str(pack_info.white_count) + " " + LocalizationManager.translate("pack_white_cards")
	else:
		count_label.text = LocalizationManager.translate("pack_coming_soon")
	count_label.add_theme_font_size_override("font_size", 26)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if not pack_info.available:
		count_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
	vbox.add_child(count_label)
	
	# Botão de seleção
	var select_btn = Button.new()
	if pack_info.available:
		select_btn.text = LocalizationManager.translate("pack_play")
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = Color(1, 0.85, 0.3, 1)
		btn_style.set_corner_radius_all(15)
		select_btn.add_theme_stylebox_override("normal", btn_style)
		select_btn.add_theme_stylebox_override("hover", btn_style)
		select_btn.add_theme_stylebox_override("pressed", btn_style)
		select_btn.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	else:
		select_btn.text = LocalizationManager.translate("pack_locked")
		select_btn.disabled = true
	select_btn.add_theme_font_size_override("font_size", 28)
	select_btn.custom_minimum_size = Vector2(0, 60)
	
	select_btn.pressed.connect(func():
		UIManager.safe_vibrate(50)
		selected_pack = pack_info.id
		MultiplayerManager.game_settings["pack"] = selected_pack
		overlay.queue_free()
		popup.queue_free()
		_create_room_with_pack(player_name)
	)
	vbox.add_child(select_btn)
	return card

func _create_room_with_pack(player_name: String):
	_show_status(LocalizationManager.translate("lobby_creating_room"), Color.YELLOW)
	
	MultiplayerManager.game_settings["pending_player_name"] = player_name
	
	var code = MultiplayerManager.create_room(player_name)
	if not code.is_empty():
		_enter_room_mode(true)
		room_code_value.text = code
		_show_status(LocalizationManager.translate("lobby_room_created"), Color.GREEN)
	else:
		_show_status(LocalizationManager.translate("lobby_create_error"), Color.RED)
