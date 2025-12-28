extends Control

@onready var name_input = $VBox/NameContainer/NameInput
@onready var buttons_container = $VBox/ButtonsContainer
@onready var join_container = $VBox/JoinContainer
@onready var code_input = $VBox/JoinContainer/CodeInput
@onready var room_code_display = $VBox/RoomCodeDisplay
@onready var status_label = $VBox/StatusLabel
@onready var players_panel = $VBox/PlayersPanel
@onready var players_list = $VBox/PlayersPanel/VBox/PlayersList
@onready var players_title = $VBox/PlayersPanel/VBox/PlayersTitle
@onready var settings_container = $VBox/SettingsContainer
@onready var points_input = $VBox/SettingsContainer/PointsInput
@onready var start_game_btn = $VBox/StartGameBtn
@onready var back_btn = $VBox/BackBtn

var is_in_room = false

func _ready():
	# Conectar sinais do MultiplayerManager
	MultiplayerManager.room_code_generated.connect(_on_room_code_generated)
	MultiplayerManager.player_list_updated.connect(_on_player_list_updated)
	MultiplayerManager.connection_succeeded.connect(_on_connection_succeeded)
	MultiplayerManager.connection_failed.connect(_on_connection_failed)
	MultiplayerManager.server_disconnected.connect(_on_server_disconnected)
	MultiplayerManager.game_started.connect(_on_game_started)
	
	# Estilo do painel
	_apply_panel_style()
	
	# Nome padrão
	name_input.text = "Jogador" + str(randi() % 1000)

func _apply_panel_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 1)
	style.set_corner_radius_all(20)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.3, 0.3, 1)
	players_panel.add_theme_stylebox_override("panel", style)

func _on_create_room_pressed():
	var player_name = name_input.text.strip_edges()
	if player_name.is_empty():
		_show_status("Digite seu nome!", Color.RED)
		return
	
	_show_status("Criando sala...", Color.YELLOW)
	
	var code = MultiplayerManager.create_room(player_name)
	if code.is_empty():
		_show_status("Erro ao criar sala!", Color.RED)
		return
	
	_enter_room_mode(true)

func _on_join_room_pressed():
	join_container.visible = true
	buttons_container.visible = false
	code_input.grab_focus()

func _on_connect_pressed():
	var player_name = name_input.text.strip_edges()
	if player_name.is_empty():
		_show_status("Digite seu nome!", Color.RED)
		return
	
	var code = code_input.text.strip_edges().to_upper()
	if code.length() != 6:
		_show_status("Código deve ter 6 caracteres!", Color.RED)
		return
	
	_show_status("Procurando sala " + code + "...", Color.YELLOW)
	
	var success = await MultiplayerManager.join_room(code, player_name)
	if not success:
		_show_status("Sala não encontrada!", Color.RED)

func _on_start_game_pressed():
	var players = MultiplayerManager.get_player_list()
	if players.size() < MultiplayerManager.MIN_PLAYERS:
		_show_status("Mínimo de " + str(MultiplayerManager.MIN_PLAYERS) + " jogadores!", Color.RED)
		return
	
	# Salvar configurações
	MultiplayerManager.set_game_settings({
		"points_to_win": int(points_input.value)
	})
	
	MultiplayerManager.start_game()

func _on_back_pressed():
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
		room_code_display.visible = true
		settings_container.visible = true
		start_game_btn.visible = true
	
	back_btn.text = "Sair da Sala"

func _exit_room_mode():
	is_in_room = false
	buttons_container.visible = true
	join_container.visible = false
	players_panel.visible = false
	room_code_display.visible = false
	settings_container.visible = false
	start_game_btn.visible = false
	name_input.editable = true
	back_btn.text = "← Voltar"
	_show_status("", Color.WHITE)

func _show_status(text: String, color: Color):
	status_label.text = text
	status_label.modulate = color

func _update_players_list(players: Array):
	# Limpar lista
	for child in players_list.get_children():
		child.queue_free()
	
	# Adicionar jogadores
	for player in players:
		var label = Label.new()
		var prefix = "👑 " if player.get("is_host", false) else "👤 "
		label.text = prefix + player.get("name", "???")
		label.add_theme_font_size_override("font_size", 28)
		players_list.add_child(label)
	
	# Atualizar título
	players_title.text = "Jogadores (" + str(players.size()) + "/15)"
	
	# Habilitar/desabilitar botão de iniciar
	if MultiplayerManager.is_host:
		start_game_btn.disabled = players.size() < MultiplayerManager.MIN_PLAYERS
		if players.size() < MultiplayerManager.MIN_PLAYERS:
			_show_status("Aguardando mais jogadores...", Color.YELLOW)
		else:
			_show_status("Pronto para iniciar!", Color.GREEN)

# ============================================
# CALLBACKS DO MULTIPLAYER MANAGER
# ============================================

func _on_room_code_generated(code: String):
	room_code_display.text = "Código: " + code
	_show_status("Sala criada! Compartilhe o código.", Color.GREEN)

func _on_player_list_updated(players: Array):
	_update_players_list(players)

func _on_connection_succeeded():
	_enter_room_mode(false)
	_show_status("Conectado!", Color.GREEN)

func _on_connection_failed():
	_show_status("Falha na conexão!", Color.RED)

func _on_server_disconnected():
	_exit_room_mode()
	_show_status("Host desconectou!", Color.RED)

func _on_game_started():
	# Ir para a tela do jogo
	var game_scene = load("res://Scenes/absurd_cards_game.tscn")
	var game = game_scene.instantiate()
	
	var current = get_tree().current_scene
	get_tree().root.add_child(game)
	get_tree().set_current_scene(game)
	if current and is_instance_valid(current):
		current.queue_free()
