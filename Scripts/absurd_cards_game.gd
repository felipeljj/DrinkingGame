extends Control

# Estados do jogo
enum GameState {
	WAITING_FOR_PLAYERS,
	PLAYERS_CHOOSING,
	JUDGE_CHOOSING,
	SHOWING_WINNER,
	GAME_OVER
}

# Referências - TopBar
@onready var round_label = $TopBar/RoundLabel
@onready var judge_label = $TopBar/JudgeLabel
@onready var my_score_button = $TopBar/MyScoreButton

# Referências - Ranking Popup
@onready var ranking_popup = $RankingPopup
@onready var ranking_panel = $RankingPopup/RankingPanel
@onready var score_list = $RankingPopup/RankingPanel/VBox/ScoreList

# Referências - PlayerView
@onready var player_view = $PlayerView
@onready var black_card_panel = $PlayerView/BlackCardPanel
@onready var black_card_label = $PlayerView/BlackCardPanel/BlackCardLabel
@onready var status_label = $PlayerView/StatusLabel
@onready var card_carousel = $PlayerView/CardCarousel
@onready var card_counter = $PlayerView/CardCarousel/CardCounter
@onready var swipe_hint = $PlayerView/CardCarousel/SwipeHint
@onready var send_button = $PlayerView/SendButton

# Referências - JudgeView
@onready var judge_view = $JudgeView
@onready var black_card_panel_judge = $JudgeView/BlackCardPanelJudge
@onready var black_card_label_judge = $JudgeView/BlackCardPanelJudge/BlackCardLabel
@onready var judge_status = $JudgeView/JudgeStatus
@onready var waiting_indicator = $JudgeView/WaitingIndicator
@onready var judge_card_carousel = $JudgeView/JudgeCardCarousel
@onready var judge_card_counter = $JudgeView/JudgeCardCarousel/CardCounter
@onready var confirm_selection_button = $JudgeView/ConfirmSelectionButton
@onready var judge_swipe_hint = $JudgeView/JudgeCardCarousel/SwipeHint

# Referências - Gerais
@onready var leave_button = $LeaveButton

# Estado do jogo
var current_state: GameState = GameState.WAITING_FOR_PLAYERS
var current_round: int = 1
var current_judge_index: int = 0
var points_to_win: int = 5
var is_judge: bool = false

# Cartas
var black_cards: Array = []
var white_cards: Array = []
var my_hand: Array = []
var current_card_index: int = 0
var played_cards: Dictionary = {}  # peer_id -> card_text
var bot_hands: Dictionary = {}  # bot_peer_id -> cards array

# Carrossel do Juiz
var judge_cards_list: Array = [] 
var judge_card_index: int = 0
var judge_card_nodes: Dictionary = {} 

# Gerenciamento de Deck (Host)
var white_deck_index: int = 0 

# Jogadores
var players: Array = []
var scores: Dictionary = {}  # peer_id -> score

# Swipe
var swipe_start_pos: Vector2 = Vector2.ZERO
var is_swiping: bool = false
const SWIPE_THRESHOLD = 80

func _ready():
	# Conectar sinais
	MultiplayerManager.player_disconnected.connect(_on_player_disconnected)
	
	# Aplicar estilos
	_apply_styles()
	
	# Inicializar jogo
	_initialize_game()

func _apply_styles():
	# ============================================
	# ESTILO DA CARTA PRETA (PERGUNTA)
	# ============================================
	var black_style = StyleBoxFlat.new()
	black_style.bg_color = Color(0.02, 0.02, 0.02, 1)
	black_style.set_corner_radius_all(20)
	black_style.border_width_left = 3
	black_style.border_width_right = 3
	black_style.border_width_top = 3
	black_style.border_width_bottom = 3
	black_style.border_color = Color(1, 1, 1, 0.9)
	black_style.shadow_size = 30
	black_style.shadow_color = Color(0, 0, 0, 0.6)
	
	black_card_panel.add_theme_stylebox_override("panel", black_style)
	
	# Tamanho da carta preta (Player) - mais visível
	var card_w = 420
	var card_h = 280
	
	black_card_panel.custom_minimum_size = Vector2(card_w, card_h)
	black_card_panel.size = Vector2(card_w, card_h)
	black_card_panel.anchors_preset = Control.PRESET_CENTER_TOP
	black_card_panel.position.x = (1080 - card_w) / 2
	black_card_panel.position.y = 20
	
	# Label da carta preta
	black_card_label.add_theme_font_size_override("font_size", 28)
	black_card_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	
	# ============================================
	# STATUS LABEL (PLAYER)
	# ============================================
	status_label.position.y = 320
	status_label.add_theme_font_size_override("font_size", 32)
	status_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
	
	# ============================================
	# CARROSSEL DO JOGADOR
	# ============================================
	card_carousel.position.y = 360
	
	# ============================================
	# ESTILO DA CARTA PRETA (JUIZ)
	# ============================================
	black_card_panel_judge.add_theme_stylebox_override("panel", black_style)
	black_card_panel_judge.custom_minimum_size = Vector2(card_w, card_h)
	black_card_panel_judge.size = Vector2(card_w, card_h)
	black_card_panel_judge.anchors_preset = Control.PRESET_CENTER_TOP
	black_card_panel_judge.position.x = (1080 - card_w) / 2
	black_card_panel_judge.position.y = 20
	
	black_card_label_judge.add_theme_font_size_override("font_size", 26)
	black_card_label_judge.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	
	# ============================================
	# STATUS LABELS (JUIZ)
	# ============================================
	judge_status.position.y = 320
	judge_status.add_theme_font_size_override("font_size", 34)
	judge_status.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
	
	waiting_indicator.position.y = 370
	waiting_indicator.add_theme_font_size_override("font_size", 60)
	
	# ============================================
	# CARROSSEL DO JUIZ
	# ============================================
	judge_card_carousel.position.y = 420
	
	# ============================================
	# BOTÃO ENVIAR (PREMIUM)
	# ============================================
	var send_style = StyleBoxFlat.new()
	send_style.bg_color = Color(0.15, 0.75, 0.35, 1)
	send_style.set_corner_radius_all(50)
	send_style.shadow_size = 15
	send_style.shadow_color = Color(0.15, 0.75, 0.35, 0.4)
	
	var send_hover = StyleBoxFlat.new()
	send_hover.bg_color = Color(0.2, 0.85, 0.4, 1)
	send_hover.set_corner_radius_all(50)
	send_hover.shadow_size = 20
	send_hover.shadow_color = Color(0.2, 0.85, 0.4, 0.5)
	
	send_button.add_theme_stylebox_override("normal", send_style)
	send_button.add_theme_stylebox_override("hover", send_hover)
	send_button.add_theme_stylebox_override("pressed", send_style)
	send_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	send_button.add_theme_font_size_override("font_size", 40)
	
	# ============================================
	# TOP BAR STYLING
	# ============================================
	round_label.add_theme_font_size_override("font_size", 32)
	round_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
	
	judge_label.add_theme_font_size_override("font_size", 32)
	
	my_score_button.add_theme_font_size_override("font_size", 36)
	my_score_button.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
	my_score_button.custom_minimum_size = Vector2(350, 60)
	
	# ============================================
	# BOTÃO CONFIRMAR VENCEDOR (PREMIUM DOURADO)
	# ============================================
	var confirm_style = StyleBoxFlat.new()
	confirm_style.bg_color = Color(0.9, 0.7, 0.1, 1)
	confirm_style.set_corner_radius_all(25)
	confirm_style.shadow_size = 20
	confirm_style.shadow_color = Color(0.9, 0.7, 0.1, 0.4)
	
	var confirm_hover = StyleBoxFlat.new()
	confirm_hover.bg_color = Color(1.0, 0.8, 0.2, 1)
	confirm_hover.set_corner_radius_all(25)
	confirm_hover.shadow_size = 25
	confirm_hover.shadow_color = Color(1.0, 0.8, 0.2, 0.5)
	
	confirm_selection_button.add_theme_stylebox_override("normal", confirm_style)
	confirm_selection_button.add_theme_stylebox_override("hover", confirm_hover)
	confirm_selection_button.add_theme_stylebox_override("pressed", confirm_style)
	confirm_selection_button.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	confirm_selection_button.add_theme_font_size_override("font_size", 32)
	confirm_selection_button.text = " " + LocalizationManager.translate("game_choose_winner")
	
	# ============================================
	# BOTÃO SAIR (CENTRALIZADO E MAIOR)
	# ============================================
	leave_button.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	leave_button.offset_left = -150
	leave_button.offset_right = 150
	leave_button.offset_top = -100
	leave_button.offset_bottom = -20
	leave_button.add_theme_font_size_override("font_size", 36)
	leave_button.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))

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
	
	# Randomizar decks (CRÍTICO para não repetir ordem)
	black_cards.shuffle()
	white_cards.shuffle()
	white_deck_index = 0
	
	# Distribuir cartas brancas para cada jogador
	var cards_per_player = 10
	
	for player in players:
		var player_cards = []
		for i in range(cards_per_player):
			if white_deck_index < white_cards.size():
				player_cards.append(white_cards[white_deck_index])
				white_deck_index += 1
			else:
				# Se acabar as cartas (improvável com decks grandes, mas possível)
				# O ideal seria reembaralhar as descartadas, mas por simplificação vamos reiniciar
				white_deck_index = 0
				white_cards.shuffle()
				player_cards.append(white_cards[white_deck_index])
				white_deck_index += 1
		
		# Se for bot, armazenar localmente
		if MultiplayerManager.is_host:
			if MultiplayerManager.is_bot(player.peer_id):
				bot_hands[player.peer_id] = player_cards
			else:
				# Enviar cartas para o jogador real
				if player.peer_id == 1:  # Host
					my_hand = player_cards
				else:
					_receive_hand.rpc_id(player.peer_id, player_cards)
	
	# Iniciar primeira rodada
	_start_round.rpc(current_round, current_judge_index)

@rpc("authority", "call_local", "reliable")
func _receive_hand(cards: Array):
	my_hand = cards
	# Resetar índice se receber nova mão completa (ex: reconexão ou inicio)
	current_card_index = 0

@rpc("authority", "call_local", "reliable")
func _receive_new_card(card_text: String):
	# Adicionar nova carta recebida (Replenishment)
	my_hand.append(card_text)
	
	# Se estiver aguardando (não jogando), atualizar UI se necessário
	# Mas geralmente isso acontece no final do turno.
	# Apenas adicionar e na próxima vez que abrir o carrossel ela estará lá.
	# Se quisermos feedback visual imediato:
	if current_state != GameState.PLAYERS_CHOOSING:
		# Talvez mostrar um toast "Nova carta recebida!"
		pass

@rpc("authority", "call_local", "reliable")
func _start_round(round_num: int = -1, judge_idx: int = -1):
	current_state = GameState.PLAYERS_CHOOSING
	played_cards.clear()
	current_card_index = 0
	
	# Sincronizar valores recebidos do host
	if round_num >= 0:
		current_round = round_num
	if judge_idx >= 0:
		current_judge_index = judge_idx
	
	# Atualizar UI
	round_label.text = LocalizationManager.translate("game_round") % current_round
	
	# Determinar juiz
	var judge = players[current_judge_index % players.size()]
	judge_label.text = LocalizationManager.translate("game_judge") % judge.name
	
	# Verificar se EU sou o juiz
	var my_peer_id = MultiplayerManager.get_my_peer_id()
	is_judge = (judge.peer_id == my_peer_id)
	
	# Mostrar view apropriada
	player_view.visible = not is_judge
	judge_view.visible = is_judge
	
	# Mostrar carta preta (host envia)
	if MultiplayerManager.is_host:
		var black_card = black_cards[current_round - 1] if current_round <= black_cards.size() else LocalizationManager.translate("notification_cards_finished")
		_show_black_card.rpc(black_card)

@rpc("authority", "call_local", "reliable")
func _show_black_card(card_text: String):
	# Atualizar carta preta em ambas as views
	black_card_label.text = card_text
	black_card_label_judge.text = card_text
	
	if is_judge:
		# View do juiz
		judge_status.text = "👑 Você é o Juiz! Aguardando respostas..."
		waiting_indicator.visible = true
		judge_card_carousel.visible = false
		confirm_selection_button.visible = false
		judge_swipe_hint.visible = false
	else:
		# View do jogador - inicia o carrossel
		status_label.text = ""
		send_button.visible = false
		_init_carousel()
	
	_update_scores_display()
	
	# Fazer bots jogarem automaticamente
	if MultiplayerManager.is_host:
		_make_bots_play()

# ============================================
# CARROSSEL DE CARTAS (PLAYER) - COVERFLOW
# ============================================

var card_nodes: Dictionary = {}  # hand_index -> Panel
const CENTER_CARD_SCALE = 1.0
const SIDE_CARD_SCALE = 0.7
const FAR_CARD_SCALE = 0.5
const CENTER_Y_OFFSET = 0
const SIDE_Y_OFFSET = 60
const FAR_Y_OFFSET = 90
const CARD_SPACING = 220
const CENTER_X = 540

func _init_carousel():
	# Criar todas as cartas da mão uma única vez
	for node in card_nodes.values():
		if is_instance_valid(node):
			node.queue_free()
	card_nodes.clear()
	
	if my_hand.is_empty():
		return
	
	for i in range(my_hand.size()):
		var card = _create_coverflow_card(my_hand[i])
		card_carousel.add_child(card)
		card_nodes[i] = card
		
		# Posicionar inicialmente (fora da tela ou na posição correta)
		var offset = i - current_card_index
		_position_card_instant(card, offset)
	
	_update_cards_visibility()
	card_counter.text = str(current_card_index + 1) + " / " + str(my_hand.size())
	send_button.visible = true
	swipe_hint.visible = false

func _update_carousel_positions():
	# Animar cada carta para sua nova posição baseada no offset atual
	for i in card_nodes.keys():
		var card = card_nodes[i]
		if not is_instance_valid(card):
			continue
		
		var offset = i - current_card_index
		
		# Lidar com wrap-around para muitas cartas
		if my_hand.size() > 4:
			if offset > my_hand.size() / 2:
				offset -= my_hand.size()
			elif offset < -my_hand.size() / 2:
				offset += my_hand.size()
		
		_position_card_animated(card, offset)
	
	_update_cards_visibility()
	card_counter.text = str(current_card_index + 1) + " / " + str(my_hand.size())

func _update_cards_visibility():
	# Mostrar apenas cartas próximas (offset -2 a +2)
	for i in card_nodes.keys():
		var card = card_nodes[i]
		if not is_instance_valid(card):
			continue
		
		var offset = i - current_card_index
		
		if my_hand.size() > 4:
			if offset > my_hand.size() / 2:
				offset -= my_hand.size()
			elif offset < -my_hand.size() / 2:
				offset += my_hand.size()

		card.visible = abs(offset) <= 1
	
	# Atrasar reordenação para sincronizar com animação
	# Guardar índice atual para verificar se mudou durante o delay
	var expected_idx = current_card_index
	await get_tree().create_timer(0.15).timeout
	
	# Se o usuário deslizou novamente durante o delay, cancelar esta reordenação
	if current_card_index != expected_idx:
		return
	_reorder_carousel_cards(card_nodes, current_card_index, my_hand.size())

func _create_coverflow_card(text: String) -> Panel:
	var panel = Panel.new()
	var base_width = 680
	var base_height = 900
	panel.custom_minimum_size = Vector2(base_width, base_height)
	panel.size = Vector2(base_width, base_height)
	panel.pivot_offset = Vector2(base_width / 2, base_height / 2)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 1)
	style.set_corner_radius_all(25)
	style.shadow_size = 25
	style.shadow_color = Color(0, 0, 0, 0.5)
	panel.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	label.add_theme_font_size_override("font_size", 56)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 40
	label.offset_top = 40
	label.offset_right = -40
	label.offset_bottom = -40
	panel.add_child(label)
	
	return panel

func _get_card_transform(offset: int) -> Dictionary:
	var target_scale: float
	var target_y: float
	var target_x: float
	
	var abs_offset = abs(offset)
	var base_x = CENTER_X - 340  # Metade do tamanho da carta (680/2)
	
	if abs_offset == 0:
		target_scale = CENTER_CARD_SCALE
		target_y = CENTER_Y_OFFSET
		target_x = base_x
	elif abs_offset == 1:
		target_scale = SIDE_CARD_SCALE
		target_y = SIDE_Y_OFFSET
		target_x = base_x + (offset * CARD_SPACING)
	elif abs_offset == 2:
		target_scale = FAR_CARD_SCALE
		target_y = FAR_Y_OFFSET
		target_x = base_x + (offset * (CARD_SPACING - 30))
	else:
		# Fora da tela
		target_scale = 0.3
		target_y = FAR_Y_OFFSET + 50
		target_x = base_x + (offset * CARD_SPACING)
	
	return {"scale": target_scale, "x": target_x, "y": target_y}

func _position_card_instant(card: Panel, offset: int):
	var transform = _get_card_transform(offset)
	card.scale = Vector2(transform.scale, transform.scale)
	card.position = Vector2(transform.x, transform.y)

func _position_card_animated(card: Panel, offset: int):
	var transform = _get_card_transform(offset)
	
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", Vector2(transform.scale, transform.scale), 0.3)
	tween.tween_property(card, "position", Vector2(transform.x, transform.y), 0.3)

func _input(event):
	# Se ranking estiver aberto, verificar clique fora para fechar
	if ranking_popup.visible and event is InputEventMouseButton and event.pressed:
		var local_event = ranking_panel.make_input_local(event)
		if not Rect2(Vector2.ZERO, ranking_panel.size).has_point(local_event.position):
			_on_close_ranking_pressed()
			return

	# Ignorar se ranking aberto
	if ranking_popup.visible:
		return
		
	# Lógica de Swipe
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			swipe_start_pos = event.position
			is_swiping = true
		else:
			if is_swiping:
				var swipe_delta = event.position.x - swipe_start_pos.x
				if abs(swipe_delta) > SWIPE_THRESHOLD:
					if swipe_delta > 0:
						_handle_swipe_right()
					else:
						_handle_swipe_left()
			is_swiping = false

func _handle_swipe_right():
	# Swipe Right (Voltar/Anterior)
	if current_state == GameState.PLAYERS_CHOOSING and not is_judge:
		_previous_card()
	elif current_state == GameState.JUDGE_CHOOSING and is_judge and judge_card_carousel.visible:
		_previous_judge_card()

func _handle_swipe_left():
	# Swipe Left (Avançar/Próximo)
	if current_state == GameState.PLAYERS_CHOOSING and not is_judge:
		_next_card()
	elif current_state == GameState.JUDGE_CHOOSING and is_judge and judge_card_carousel.visible:
		_next_judge_card()

func _next_card():
	if my_hand.is_empty() or my_hand.size() <= 1:
		return
	
	current_card_index = (current_card_index + 1) % my_hand.size()
	UIManager.safe_vibrate(20)
	_update_carousel_positions()

func _previous_card():
	if my_hand.is_empty() or my_hand.size() <= 1:
		return
	
	current_card_index = (current_card_index - 1 + my_hand.size()) % my_hand.size()
	UIManager.safe_vibrate(20)
	_update_carousel_positions()

func _on_send_pressed():
	if my_hand.is_empty() or current_state != GameState.PLAYERS_CHOOSING:
		return
	
	UIManager.safe_vibrate(50)
	
	var card_text = my_hand[current_card_index]
	
	# Remover carta da mão
	my_hand.remove_at(current_card_index)
	if current_card_index >= my_hand.size():
		current_card_index = max(0, my_hand.size() - 1)
	
	# Enviar carta ao host
	if MultiplayerManager.is_host:
		_submit_card(card_text)
	else:
		_submit_card.rpc_id(1, card_text)
	
	# Atualizar UI
	send_button.visible = false
	swipe_hint.visible = false
	status_label.text = "✅ Carta enviada! Aguardando..."
	
	# Animar todas as cartas saindo para cima
	for node in card_nodes.values():
		if is_instance_valid(node):
			var tween = create_tween()
			tween.tween_property(node, "position:y", -800, 0.4).set_trans(Tween.TRANS_BACK)
			tween.parallel().tween_property(node, "modulate:a", 0.0, 0.4)
			tween.tween_callback(node.queue_free)
	card_nodes.clear()

@rpc("any_peer", "reliable")
func _submit_card(card_text: String):
	if not MultiplayerManager.is_host:
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	# Se for chamada local (Host jogando), ID vem 0. Host sempre é 1.
	if sender_id == 0:
		sender_id = 1
		
	played_cards[sender_id] = card_text
	
	# Verificar se todos jogaram
	_check_all_played()

func _check_all_played():
	var judge = players[current_judge_index % players.size()]
	var expected_players = players.size() - 1  # Todos exceto o juiz
	
	if played_cards.size() >= expected_players:
		# Revelar cartas
		_reveal_cards.rpc(played_cards)

@rpc("authority", "call_local", "reliable")
func _reveal_cards(cards: Dictionary):
	current_state = GameState.JUDGE_CHOOSING
	played_cards = cards
	
	if is_judge:
		# Mostrar cartas para o juiz escolher
		waiting_indicator.visible = false
		judge_status.text = "👑 Escolha a melhor resposta!"
		
		# Iniciar carrossel do juiz
		_init_judge_carousel()
	else:
		status_label.text = "Aguardando o juiz escolher..."
	
	# Se o juiz é um bot, fazer ele escolher
	if MultiplayerManager.is_host:
		var judge = players[current_judge_index % players.size()]
		if MultiplayerManager.is_bot(judge.peer_id):
			_make_bot_judge_choose()

# ============================================
# CARROSSEL DO JUIZ
# ============================================

func _init_judge_carousel():
	# Preparar lista de cartas
	judge_cards_list.clear()
	for peer_id in played_cards:
		judge_cards_list.append({"id": peer_id, "text": played_cards[peer_id]})
	
	judge_cards_list.shuffle()
	judge_card_index = 0
	
	# Limpar nós
	for node in judge_card_nodes.values():
		if is_instance_valid(node):
			node.queue_free()
	judge_card_nodes.clear()
	
	if judge_cards_list.is_empty():
		return
		
	judge_card_carousel.visible = true
	confirm_selection_button.visible = true
	judge_swipe_hint.visible = false
	
	for i in range(judge_cards_list.size()):
		var card = _create_judge_coverflow_card(judge_cards_list[i].text)
		judge_card_carousel.add_child(card)
		judge_card_nodes[i] = card
		
		# Posição inicial
		var offset = i - judge_card_index
		_position_judge_card_instant(card, offset)
		
		# Salvar escala alvo
		var target_scale = card.scale
		
		# Animação de entrada
		card.modulate.a = 0
		card.scale = Vector2(0.1, 0.1)
		
		# Animar entrada (efeito cascata)
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "modulate:a", 1.0, 0.5).set_delay(i * 0.15)
		tween.tween_property(card, "scale", target_scale, 0.5).set_delay(i * 0.15)
		
		# Som
		tween.tween_callback(func(): UIManager.safe_vibrate(10)).set_delay(i * 0.15)
	
	judge_card_counter.text = str(judge_card_index + 1) + " / " + str(judge_cards_list.size())
	_reorder_carousel_cards(judge_card_nodes, judge_card_index, judge_cards_list.size())

func _update_judge_carousel_positions():
	for i in judge_card_nodes.keys():
		var card = judge_card_nodes[i]
		if not is_instance_valid(card):
			continue
		
		var offset = i - judge_card_index
		
		# Wrap around
		var size = judge_cards_list.size()
		if size > 4:
			if offset > size / 2:
				offset -= size
			elif offset < -size / 2:
				offset += size
				
		_position_judge_card_animated(card, offset)
		

		# Atualizar visibilidade
		card.visible = abs(offset) <= 2

	judge_card_counter.text = str(judge_card_index + 1) + " / " + str(judge_cards_list.size())
	
	# Atrasar reordenação para sincronizar com animação
	var expected_idx = judge_card_index
	await get_tree().create_timer(0.15).timeout
	
	# Se o usuário deslizou novamente durante o delay, cancelar esta reordenação
	if judge_card_index != expected_idx:
		return
	_reorder_carousel_cards(judge_card_nodes, judge_card_index, judge_cards_list.size())

func _create_judge_coverflow_card(text: String) -> Panel:
	var panel = Panel.new()
	var base_width = 680
	var base_height = 900
	panel.custom_minimum_size = Vector2(base_width, base_height)
	panel.size = Vector2(base_width, base_height)
	panel.pivot_offset = Vector2(base_width / 2, base_height / 2)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 1)
	style.set_corner_radius_all(25)
	style.shadow_size = 25
	style.shadow_color = Color(0, 0, 0, 0.5)
	panel.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	label.add_theme_font_size_override("font_size", 56)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 40
	label.offset_top = 40
	label.offset_right = -40
	label.offset_bottom = -40
	panel.add_child(label)
	
	return panel

func _position_judge_card_instant(card: Panel, offset: int):
	var transform = _get_card_transform(offset) # Reutilizando a função transform do jogador pois é o mesmo layout visual
	card.scale = Vector2(transform.scale, transform.scale)
	card.position = Vector2(transform.x, transform.y)

func _position_judge_card_animated(card: Panel, offset: int):
	var transform = _get_card_transform(offset)
	
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "scale", Vector2(transform.scale, transform.scale), 0.3)
	tween.tween_property(card, "position", Vector2(transform.x, transform.y), 0.3)

func _next_judge_card():
	if judge_cards_list.is_empty(): return
	judge_card_index = (judge_card_index + 1) % judge_cards_list.size()
	UIManager.safe_vibrate(20)
	_update_judge_carousel_positions()

func _previous_judge_card():
	if judge_cards_list.is_empty(): return
	var size = judge_cards_list.size()
	judge_card_index = (judge_card_index - 1 + size) % size
	UIManager.safe_vibrate(20)
	_update_judge_carousel_positions()

func _on_confirm_selection_pressed():
	if judge_cards_list.is_empty(): return
	
	var selected_item = judge_cards_list[judge_card_index]
	_on_judge_selected_card(selected_item.text)

func _on_judge_selected_card(card_text: String):
	if current_state != GameState.JUDGE_CHOOSING or not is_judge:
		return
	
	UIManager.safe_vibrate(50)
	confirm_selection_button.visible = false
	
	# Animar escolha (Mais lento e visível)
	var center_card = judge_card_nodes[judge_card_index]
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(center_card, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(center_card, "modulate", Color.GREEN, 0.5)
	
	await tween.finished
	
	# Manter o destaque por um momento
	await get_tree().create_timer(1.0).timeout
	
	# Encontrar quem jogou essa carta
	var winner_id = -1
	for id in played_cards:
		if played_cards[id] == card_text:
			winner_id = id
			break
	
	if winner_id != -1:
		_announce_winner.rpc(winner_id, card_text)

@rpc("authority", "call_local", "reliable")
func _announce_winner(winner_id: int, winning_card: String):
	current_state = GameState.SHOWING_WINNER
	
	# Esconder UI do juiz
	judge_card_carousel.visible = false
	confirm_selection_button.visible = false
	judge_swipe_hint.visible = false
	
	# Adicionar ponto
	if scores.has(winner_id):
		scores[winner_id] += 1
	
	# Encontrar nome do vencedor
	var winner_name = "???"
	for player in players:
		if player.peer_id == winner_id:
			winner_name = player.name
			break
	
	# Mostrar vencedor em ambas as views
	var my_peer_id = MultiplayerManager.get_my_peer_id()
	var winner_text: String
	
	if winner_id == my_peer_id:
		winner_text = "🎉 VOCÊ GANHOU! 🎉"
	else:
		winner_text = "🎉 " + winner_name + " ganhou!"
	
	status_label.text = winner_text
	judge_status.text = winner_text
	
	# Efeito de confete
	ParticlesManager.create_confetti(self, Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2), Color.GOLD, 50)
	ParticlesManager.create_star_particles(self, Vector2(get_viewport_rect().size.x / 2, 300), Color.YELLOW)
	
	# Feedback tátil
	UIManager.safe_vibrate(100)
	
	_update_scores_display()
	
	# Verificar fim de jogo
	if scores[winner_id] >= points_to_win:
		await get_tree().create_timer(3.0).timeout
		_end_game.rpc(winner_id)
	else:
		await get_tree().create_timer(4.0).timeout
		if MultiplayerManager.is_host:
			current_round += 1
			current_judge_index += 1
			
			# Repor cartas antes da próxima rodada
			_replenish_hands()
			
			_start_round.rpc(current_round, current_judge_index)

@rpc("authority", "call_local", "reliable")
func _end_game(winner_id: int):
	current_state = GameState.GAME_OVER
	
	var winner_name = "???"
	for player in players:
		if player.peer_id == winner_id:
			winner_name = player.name
			break
	
	var winner_text = " " + winner_name + " VENCEU!"
	status_label.text = winner_text
	judge_status.text = winner_text
	black_card_label.text = "FIM DE JOGO!\n\n" + winner_name + " é o campeão!"
	black_card_label_judge.text = "FIM DE JOGO!\n\n" + winner_name + " é o campeão!"
	
	# chuva de confetes
	for i in range(5):
		await get_tree().create_timer(0.3).timeout
		ParticlesManager.create_confetti(self, Vector2(randf_range(100, 900), randf_range(100, 600)), Color.WHITE, 40)

func _update_scores_display():
	# 1. Atualizar botão de pontos do jogador local
	var my_peer_id = MultiplayerManager.get_my_peer_id()
	var my_score = scores.get(my_peer_id, 0)
	my_score_button.text = " Meus Pontos: " + str(my_score)
	
	# 2. Atualizar lista do ranking popup
	for child in score_list.get_children():
		child.queue_free()
	
	# Ordenar jogadores por pontuação
	var sorted_players = []
	for player in players:
		var p_score = scores.get(player.peer_id, 0)
		sorted_players.append({"player": player, "score": p_score})
	
	sorted_players.sort_custom(func(a, b): return a.score > b.score)
	
	for item in sorted_players:
		var player = item.player
		var score = item.score
		
		var label = Label.new()
		var prefix = ""
		if player.get("is_host", false): prefix += "👑 "
		if player.get("is_bot", false): prefix += "🤖 "
		if player.peer_id == my_peer_id: prefix += "👤 "
		
		label.text = prefix + player.name + ": " + str(score) + "/" + str(points_to_win)
		label.add_theme_font_size_override("font_size", 32)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		# Destacar líder
		if item == sorted_players[0] and score > 0:
			label.add_theme_color_override("font_color", Color.GOLD)
		
		score_list.add_child(label)

func _on_my_score_button_pressed():
	ranking_popup.visible = true
	# Animação de entrada
	ranking_panel.scale = Vector2(0.8, 0.8)
	ranking_panel.modulate.a = 0
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(ranking_panel, "scale", Vector2.ONE, 0.3)
	tween.tween_property(ranking_panel, "modulate:a", 1.0, 0.3)
	
	UIManager.safe_vibrate(20)

func _on_close_ranking_pressed():
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(ranking_panel, "scale", Vector2(0.8, 0.8), 0.2)
	tween.tween_property(ranking_panel, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	ranking_popup.visible = false
	UIManager.safe_vibrate(20)

func _on_player_disconnected(peer_id: int):
	players = players.filter(func(p): return p.peer_id != peer_id)
	
	if players.size() < MultiplayerManager.MIN_PLAYERS:
		status_label.text = "Jogadores insuficientes!"
		await get_tree().create_timer(2.0).timeout
		_on_leave_pressed()

func _on_leave_pressed():
	UIManager.safe_vibrate(30)
	MultiplayerManager.leave_room()
	UIManager.change_scene_with_fade("res://Scenes/absurd_cards_lobby.tscn")

# ============================================
# LÓGICA DE BOTS
# ============================================

func _make_bots_play():
	var judge = players[current_judge_index % players.size()]
	
	for bot_id in bot_hands.keys():
		if bot_id == judge.peer_id:
			continue
		
		# Delay aleatório
		var delay = randf_range(0.5, 2.0)
		await get_tree().create_timer(delay).timeout
		
		if bot_hands.has(bot_id) and bot_hands[bot_id].size() > 0:
			var cards = bot_hands[bot_id]
			var random_index = randi() % cards.size()
			var chosen_card = cards[random_index]
			
			cards.remove_at(random_index)
			bot_hands[bot_id] = cards
			
			played_cards[bot_id] = chosen_card
			_check_all_played()

func _make_bot_judge_choose():
	var judge = players[current_judge_index % players.size()]
	
	if MultiplayerManager.is_bot(judge.peer_id):
		await get_tree().create_timer(randf_range(1.5, 3.0)).timeout
		
		var cards_values = played_cards.values()
		if cards_values.size() > 0:
			var chosen = cards_values[randi() % cards_values.size()]
			_on_judge_selected_card_by_bot(chosen)

func _on_judge_selected_card_by_bot(card_text: String):
	var winner_id = -1
	for peer_id in played_cards:
		if played_cards[peer_id] == card_text:
			winner_id = peer_id
			break
	
	if winner_id != 0:
		_announce_winner.rpc(winner_id, card_text)

# Helper para reordenar cartas (Z-Index visual)
func _reorder_carousel_cards(nodes_map: Dictionary, center_idx: int, total_count: int):
	var sort_list = []
	for i in nodes_map.keys():
		var node = nodes_map[i]
		if not is_instance_valid(node): continue
		
		var offset = i - center_idx
		if total_count > 4:
			if offset > total_count / 2: offset -= total_count
			elif offset < -total_count / 2: offset += total_count
		
		sort_list.append({"node": node, "dist": abs(offset)})
	
	# Ordenar: fundo (maior dist) primeiro
	sort_list.sort_custom(func(a, b): return a.dist > b.dist)
	
	for item in sort_list:
		item.node.move_to_front()

func _replenish_hands():
	if not MultiplayerManager.is_host:
		return
		
	# Para cada jogador que jogou uma carta nesta rodada (está em played_cards)
	for peer_id in played_cards.keys():
		var new_card = ""
		
		# Pegar próxima carta do deck
		if white_deck_index < white_cards.size():
			new_card = white_cards[white_deck_index]
			white_deck_index += 1
		else:
			# Deck acabou, reembaralhar
			white_deck_index = 0
			white_cards.shuffle()
			new_card = white_cards[white_deck_index]
			white_deck_index += 1
			
		# Distribuir
		if MultiplayerManager.is_bot(peer_id):
			if bot_hands.has(peer_id):
				bot_hands[peer_id].append(new_card)
		else:
			if peer_id == 1: # Host
				_receive_new_card(new_card) # Chama localmente mesmo
			else:
				_receive_new_card.rpc_id(peer_id, new_card)
