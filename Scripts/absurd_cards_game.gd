extends Control

# Estados do jogo
enum GameState {
	WAITING_FOR_PLAYERS,
	PLAYERS_CHOOSING,
	REVEALING_CARDS,
	JUDGE_CHOOSING,
	SHOWING_WINNER,
	GAME_OVER
}

@onready var round_label = $TopBar/RoundLabel
@onready var judge_label = $TopBar/JudgeLabel
@onready var black_card_panel = $BlackCardPanel
@onready var black_card_label = $BlackCardPanel/BlackCardLabel
@onready var status_label = $StatusLabel
@onready var played_cards_area = $PlayedCardsArea
@onready var hand_container = $HandScrollContainer/HandContainer
@onready var score_panel = $ScorePanel
@onready var score_list = $ScorePanel/VBox/ScoreList
@onready var confirm_button = $ConfirmButton
@onready var leave_button = $LeaveButton

# Estado do jogo
var current_state: GameState = GameState.WAITING_FOR_PLAYERS
var current_round: int = 1
var current_judge_index: int = 0
var points_to_win: int = 5

# Cartas
var black_cards: Array = []
var white_cards: Array = []
var my_hand: Array = []
var selected_card_index: int = -1
var played_cards: Dictionary = {}  # peer_id -> card_text

# Jogadores
var players: Array = []
var scores: Dictionary = {}  # peer_id -> score

func _ready():
	# Conectar sinais
	MultiplayerManager.player_disconnected.connect(_on_player_disconnected)
	
	# Aplicar estilos
	_apply_styles()
	
	# Inicializar jogo
	_initialize_game()

func _apply_styles():
	# Estilo da carta preta
	var black_style = StyleBoxFlat.new()
	black_style.bg_color = Color(0, 0, 0, 1)
	black_style.set_corner_radius_all(20)
	black_style.border_width_left = 4
	black_style.border_width_right = 4
	black_style.border_width_top = 4
	black_style.border_width_bottom = 4
	black_style.border_color = Color(1, 1, 1, 1)
	black_card_panel.add_theme_stylebox_override("panel", black_style)
	
	# Estilo do painel de score
	var score_style = StyleBoxFlat.new()
	score_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	score_style.set_corner_radius_all(15)
	score_panel.add_theme_stylebox_override("panel", score_style)

func _initialize_game():
	# Carregar configurações
	points_to_win = MultiplayerManager.game_settings.get("points_to_win", 5)
	
	# Carregar jogadores
	players = MultiplayerManager.get_player_list()
	
	# Inicializar scores
	for player in players:
		scores[player.peer_id] = 0
	
	# Se sou o host, distribuir cartas
	if MultiplayerManager.is_host:
		_host_start_game()

func _host_start_game():
	# Carregar cartas
	black_cards = AbsurdCardsData.get_black_cards()
	white_cards = AbsurdCardsData.get_white_cards()
	
	# Distribuir cartas brancas para cada jogador
	var cards_per_player = 10
	var card_index = 0
	
	for player in players:
		var player_cards = []
		for i in range(cards_per_player):
			if card_index < white_cards.size():
				player_cards.append(white_cards[card_index])
				card_index += 1
		
		# Enviar cartas para o jogador
		_receive_hand.rpc_id(player.peer_id, player_cards)
	
	# Iniciar primeira rodada
	_start_round.rpc()

@rpc("authority", "call_local", "reliable")
func _receive_hand(cards: Array):
	my_hand = cards
	_update_hand_display()

@rpc("authority", "call_local", "reliable")
func _start_round():
	current_state = GameState.PLAYERS_CHOOSING
	played_cards.clear()
	selected_card_index = -1
	
	# Atualizar UI
	round_label.text = "Rodada " + str(current_round)
	
	# Determinar juiz
	var judge = players[current_judge_index % players.size()]
	judge_label.text = "👑 Juiz: " + judge.name
	
	# Mostrar carta preta (host envia)
	if MultiplayerManager.is_host:
		var black_card = black_cards[current_round - 1] if current_round <= black_cards.size() else "Fim das cartas!"
		_show_black_card.rpc(black_card)

@rpc("authority", "call_local", "reliable")
func _show_black_card(card_text: String):
	black_card_label.text = card_text
	
	# Atualizar status
	var my_peer_id = MultiplayerManager.get_my_peer_id()
	var judge = players[current_judge_index % players.size()]
	
	if judge.peer_id == my_peer_id:
		status_label.text = "Você é o juiz! Aguarde os jogadores escolherem..."
		_disable_hand()
	else:
		status_label.text = "Escolha uma carta da sua mão"
		_enable_hand()
	
	# Limpar cartas jogadas
	_clear_played_cards()
	
	_update_scores_display()

func _update_hand_display():
	# Limpar mão atual
	for child in hand_container.get_children():
		child.queue_free()
	
	# Adicionar cartas
	for i in range(my_hand.size()):
		var card = _create_white_card(my_hand[i], i)
		hand_container.add_child(card)

func _create_white_card(text: String, index: int) -> Control:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(200, 280)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 1)
	style.set_corner_radius_all(15)
	panel.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	label.add_theme_font_size_override("font_size", 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 15
	label.offset_top = 15
	label.offset_right = -15
	label.offset_bottom = -15
	panel.add_child(label)
	
	var button = Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(func(): _on_card_selected(index))
	panel.add_child(button)
	
	panel.set_meta("index", index)
	
	return panel

func _on_card_selected(index: int):
	if current_state != GameState.PLAYERS_CHOOSING:
		return
	
	# Desmarcar carta anterior
	if selected_card_index >= 0:
		_set_card_selected(selected_card_index, false)
	
	# Marcar nova carta
	selected_card_index = index
	_set_card_selected(index, true)
	
	# Mostrar botão de confirmar
	confirm_button.visible = true

func _set_card_selected(index: int, selected: bool):
	if index >= hand_container.get_child_count():
		return
	
	var card = hand_container.get_child(index)
	var style = card.get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		if selected:
			style.border_width_left = 4
			style.border_width_right = 4
			style.border_width_top = 4
			style.border_width_bottom = 4
			style.border_color = Color(0.2, 0.8, 0.2, 1)
			card.position.y = -20
		else:
			style.border_width_left = 0
			style.border_width_right = 0
			style.border_width_top = 0
			style.border_width_bottom = 0
			card.position.y = 0

func _on_confirm_pressed():
	if selected_card_index < 0:
		return
	
	var card_text = my_hand[selected_card_index]
	
	# Remover carta da mão
	my_hand.remove_at(selected_card_index)
	_update_hand_display()
	
	# Enviar carta ao host
	_submit_card.rpc_id(1, card_text)
	
	# Atualizar UI
	confirm_button.visible = false
	status_label.text = "Aguardando outros jogadores..."
	_disable_hand()

@rpc("any_peer", "reliable")
func _submit_card(card_text: String):
	if not MultiplayerManager.is_host:
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	played_cards[sender_id] = card_text
	
	# Verificar se todos jogaram (exceto juiz)
	var expected_players = players.size() - 1
	if played_cards.size() >= expected_players:
		# Revelar cartas
		_reveal_cards.rpc(played_cards)

@rpc("authority", "call_local", "reliable")
func _reveal_cards(cards: Dictionary):
	current_state = GameState.JUDGE_CHOOSING
	played_cards = cards
	
	_display_played_cards()
	
	var my_peer_id = MultiplayerManager.get_my_peer_id()
	var judge = players[current_judge_index % players.size()]
	
	if judge.peer_id == my_peer_id:
		status_label.text = "Escolha a melhor resposta!"
	else:
		status_label.text = "Aguardando o juiz escolher..."

func _display_played_cards():
	_clear_played_cards()
	
	var cards_array = played_cards.values()
	cards_array.shuffle()  # Embaralhar para não revelar quem jogou
	
	for card_text in cards_array:
		var card = _create_played_card(card_text)
		played_cards_area.add_child(card)

func _create_played_card(text: String) -> Control:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(180, 200)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 1)
	style.set_corner_radius_all(12)
	panel.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	label.add_theme_font_size_override("font_size", 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 10
	label.offset_top = 10
	label.offset_right = -10
	label.offset_bottom = -10
	panel.add_child(label)
	
	# Apenas juiz pode clicar
	var my_peer_id = MultiplayerManager.get_my_peer_id()
	var judge = players[current_judge_index % players.size()]
	
	if judge.peer_id == my_peer_id:
		var button = Button.new()
		button.flat = true
		button.set_anchors_preset(Control.PRESET_FULL_RECT)
		button.pressed.connect(func(): _on_judge_selected_card(text))
		panel.add_child(button)
	
	return panel

func _on_judge_selected_card(card_text: String):
	if current_state != GameState.JUDGE_CHOOSING:
		return
	
	# Encontrar quem jogou essa carta
	var winner_id = -1
	for peer_id in played_cards:
		if played_cards[peer_id] == card_text:
			winner_id = peer_id
			break
	
	if winner_id > 0:
		_announce_winner.rpc(winner_id, card_text)

@rpc("authority", "call_local", "reliable")
func _announce_winner(winner_id: int, winning_card: String):
	current_state = GameState.SHOWING_WINNER
	
	# Adicionar ponto
	if scores.has(winner_id):
		scores[winner_id] += 1
	
	# Encontrar nome do vencedor
	var winner_name = "???"
	for player in players:
		if player.peer_id == winner_id:
			winner_name = player.name
			break
	
	status_label.text = "🎉 " + winner_name + " ganhou a rodada!"
	
	_update_scores_display()
	
	# Verificar fim de jogo
	if scores[winner_id] >= points_to_win:
		await get_tree().create_timer(2.0).timeout
		_end_game.rpc(winner_id)
	else:
		await get_tree().create_timer(3.0).timeout
		if MultiplayerManager.is_host:
			current_round += 1
			current_judge_index += 1
			_start_round.rpc()

@rpc("authority", "call_local", "reliable")
func _end_game(winner_id: int):
	current_state = GameState.GAME_OVER
	
	var winner_name = "???"
	for player in players:
		if player.peer_id == winner_id:
			winner_name = player.name
			break
	
	status_label.text = "🏆 " + winner_name + " VENCEU O JOGO!"
	black_card_label.text = "FIM DE JOGO!\n\n" + winner_name + " é o campeão!"
	
	_disable_hand()

func _update_scores_display():
	for child in score_list.get_children():
		child.queue_free()
	
	for player in players:
		var label = Label.new()
		var score = scores.get(player.peer_id, 0)
		var prefix = "👑 " if player.is_host else ""
		label.text = prefix + player.name + ": " + str(score) + "/" + str(points_to_win)
		label.add_theme_font_size_override("font_size", 24)
		score_list.add_child(label)

func _clear_played_cards():
	for child in played_cards_area.get_children():
		child.queue_free()

func _enable_hand():
	for card in hand_container.get_children():
		card.modulate.a = 1.0

func _disable_hand():
	for card in hand_container.get_children():
		card.modulate.a = 0.5

func _on_player_disconnected(peer_id: int):
	# Remover jogador da lista
	players = players.filter(func(p): return p.peer_id != peer_id)
	
	if players.size() < MultiplayerManager.MIN_PLAYERS:
		status_label.text = "Jogadores insuficientes! Jogo encerrado."
		await get_tree().create_timer(2.0).timeout
		_on_leave_pressed()

func _on_leave_pressed():
	MultiplayerManager.leave_room()
	UIManager.change_scene_with_fade("res://Scenes/game_hub.tscn")
