extends Control

var card_history: Array = []
var session_photos: Array = []
var session_start_time: int = 0

@onready var scroll_container = $ScrollContainer
@onready var cards_container = $ScrollContainer/HBoxCenter/CardsContainer

# Estatísticas calculadas
var stats: Dictionary = {}

# Controle de animações de scroll
var animated_cards: Array = []

func _ready():
	print("Wrapped iniciado!")
	print("  card_history tem ", card_history.size(), " cartas")
	print("  session_photos tem ", session_photos.size(), " fotos")
	
	_calculate_stats()
	_create_cards()
	
	# Animar entrada do primeiro card
	await get_tree().create_timer(0.3).timeout
	if is_instance_valid(cards_container) and cards_container.get_child_count() > 0:
		# Pular padding superior
		for i in range(1, cards_container.get_child_count()):
			var child = cards_container.get_child(i)
			if child is Panel:
				_animate_card_entrance(child)
				animated_cards.append(child)
				break

func _process(_delta: float):
	_check_visible_cards()

func _check_visible_cards():
	if not is_instance_valid(scroll_container) or not is_instance_valid(cards_container):
		return
	
	# Obter área visível do scroll container (relativa ao cards_container)
	var scroll_offset = scroll_container.scroll_vertical
	var viewport_height = scroll_container.size.y
	var viewport_top = scroll_offset
	var viewport_bottom = scroll_offset + viewport_height
	
	# Adicionar margem de detecção (animar antes de entrar completamente)
	var detection_margin = 200.0
	viewport_top -= detection_margin
	viewport_bottom += detection_margin
	
	for i in range(cards_container.get_child_count()):
		var card = cards_container.get_child(i)
		if not card is Panel:
			continue
		
		if card in animated_cards:
			continue
		
		# Obter posição do card relativa ao cards_container
		var card_top = card.position.y
		var card_bottom = card_top + card.size.y
		
		# Verificar se o card está dentro ou próximo da área visível
		if (card_bottom >= viewport_top and card_top <= viewport_bottom):
			_animate_card_entrance(card)
			animated_cards.append(card)

func _calculate_stats():
	# Total de cartas
	stats["total_cards"] = card_history.size()
	
	# Cartas raras
	stats["rare_cards"] = 0
	for c in card_history:
		var cat: String = c.get("category", "")
		if cat.ends_with("_raros"):
			stats["rare_cards"] += 1
	
	# Pack mais jogado
	var by_pack := {}
	for c in card_history:
		var cat: String = c.get("category", "")
		# Remover sufixo _raros para obter o pack base
		var pack_name = cat.replace("_raros", "")
		by_pack[pack_name] = by_pack.get(pack_name, 0) + 1
	
	var top_pack := ""
	var top_count := 0
	for k in by_pack.keys():
		if by_pack[k] > top_count:
			top_pack = k
			top_count = by_pack[k]
	
	stats["top_pack"] = top_pack
	stats["top_pack_count"] = top_count
	
	# Fotos tiradas
	stats["photos_count"] = session_photos.size()
	
	# Tempo de jogo
	var elapsed_ms = Time.get_ticks_msec() - session_start_time
	var elapsed_seconds = elapsed_ms / 1000.0
	var minutes = int(elapsed_seconds / 60.0)
	var hours = int(minutes / 60.0)
	minutes = minutes % 60
	
	stats["play_time_minutes"] = minutes
	stats["play_time_hours"] = hours
	stats["play_time_seconds"] = int(elapsed_seconds)
	
	# Categoria favorita (mesma lógica do pack, mas usando categoria completa)
	var by_category := {}
	for c in card_history:
		var cat: String = c.get("category", "")
		by_category[cat] = by_category.get(cat, 0) + 1
	
	var top_category := ""
	var top_category_count := 0
	for k in by_category.keys():
		if by_category[k] > top_category_count:
			top_category = k
			top_category_count = by_category[k]
	
	stats["top_category"] = top_category
	stats["top_category_count"] = top_category_count

func _create_cards():
	# Garantir que o container tenha largura mínima para centralização
	if is_instance_valid(cards_container):
		cards_container.custom_minimum_size = Vector2(800, 0)
	
	# Padding superior
	var padding_top = Control.new()
	padding_top.custom_minimum_size = Vector2(0, 50)
	padding_top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_container.add_child(padding_top)
	
	# Card 1: Introdução
	_create_intro_card()
	
	# Card 2: Total de Cartas
	_create_total_cards_card()
	
	# Card 3: Pack Mais Jogado
	if stats["top_pack"] != "":
		_create_top_pack_card()
	
	# Card 4: Cartas Raras
	if stats["rare_cards"] > 0:
		_create_rare_cards_card()
	
	# Card 5: Fotos (apenas se houver fotos)
	if stats["photos_count"] > 0:
		_create_photos_card()
	
	# Card 6: Tempo de Jogo
	_create_play_time_card()
	
	# Card 7: Categoria Favorita
	if stats["top_category"] != "":
		_create_top_category_card()
	
	# Card Final: Voltar ao Menu
	_create_final_card()
	
	# Padding inferior
	var padding_bottom = Control.new()
	padding_bottom.custom_minimum_size = Vector2(0, 50)
	padding_bottom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_container.add_child(padding_bottom)

func _create_intro_card():
	var card = _create_base_card()
	card.custom_minimum_size = Vector2(800, 600)
	
	var margin = card.get_child(0)  # MarginContainer criado em _create_base_card
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 30)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "\nDrink's Deck\nWrapped"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 80)
	var title_settings = LabelSettings.new()
	title_settings.font_size = 80
	title_settings.font_color = Color(1, 1, 1, 1)
	title_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	title.label_settings = title_settings
	vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Sua sessão de jogo"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 40)
	var subtitle_settings = LabelSettings.new()
	subtitle_settings.font_size = 40
	subtitle_settings.font_color = Color(0.8, 0.8, 0.8, 1)
	subtitle_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	subtitle.label_settings = subtitle_settings
	vbox.add_child(subtitle)
	
	cards_container.add_child(card)
	
	# Efeito de confete
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(card):
		await get_tree().process_frame  # Aguardar card estar totalmente renderizado
		var confetti_pos = Vector2(card.size.x / 2.0, card.size.y / 2.0)
		ParticlesManager.create_confetti(card, confetti_pos, Color(1, 0.843, 0, 1), 50)
		ParticlesManager.create_confetti(card, confetti_pos, Color(1, 0.2, 0.2, 1), 30)
		ParticlesManager.create_confetti(card, confetti_pos, Color(0.2, 0.6, 1, 1), 30)

func _create_total_cards_card():
	var card = _create_base_card()
	card.custom_minimum_size = Vector2(800, 500)
	
	var margin = card.get_child(0)  # MarginContainer criado em _create_base_card
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)
	
	var emoji = Label.new()
	emoji.text = "📊"
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji.add_theme_font_size_override("font_size", 100)
	vbox.add_child(emoji)
	
	var label = Label.new()
	label.text = "Total de Cartas"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 50)
	var label_settings = LabelSettings.new()
	label_settings.font_size = 50
	label_settings.font_color = Color(1, 1, 1, 1)
	label_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	label.label_settings = label_settings
	vbox.add_child(label)
	
	var counter = Label.new()
	counter.name = "Counter"
	counter.text = "0"
	counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	counter.add_theme_font_size_override("font_size", 120)
	var counter_settings = LabelSettings.new()
	counter_settings.font_size = 120
	counter_settings.font_color = Color(1, 0.843, 0, 1)
	counter_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	counter.label_settings = counter_settings
	vbox.add_child(counter)
	
	cards_container.add_child(card)
	
	# Animar contador
	_animate_counter(counter, 0, stats["total_cards"], 1.5)

func _create_top_pack_card():
	var card = _create_base_card()
	card.custom_minimum_size = Vector2(800, 500)
	
	var margin = card.get_child(0)  # MarginContainer criado em _create_base_card
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)
	
	var emoji = Label.new()
	emoji.text = "🏆"
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji.add_theme_font_size_override("font_size", 100)
	vbox.add_child(emoji)
	
	var label = Label.new()
	label.text = "Pack Mais Jogado"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 50)
	var label_settings = LabelSettings.new()
	label_settings.font_size = 50
	label_settings.font_color = Color(1, 1, 1, 1)
	label_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	label.label_settings = label_settings
	vbox.add_child(label)
	
	var pack_name = Label.new()
	pack_name.text = stats["top_pack"].capitalize()
	pack_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pack_name.add_theme_font_size_override("font_size", 80)
	var pack_settings = LabelSettings.new()
	pack_settings.font_size = 80
	pack_settings.font_color = Color(0.2, 0.8, 1, 1)
	pack_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	pack_name.label_settings = pack_settings
	vbox.add_child(pack_name)
	
	var count_label = Label.new()
	count_label.text = "jogado " + str(stats["top_pack_count"]) + " vezes"
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.add_theme_font_size_override("font_size", 40)
	var count_settings = LabelSettings.new()
	count_settings.font_size = 40
	count_settings.font_color = Color(0.8, 0.8, 0.8, 1)
	count_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	count_label.label_settings = count_settings
	vbox.add_child(count_label)
	
	cards_container.add_child(card)
	
	# Efeito de partículas
	await get_tree().create_timer(0.3).timeout
	if is_instance_valid(card):
		var particle_pos = Vector2(card.size.x / 2.0, 200)
		ParticlesManager.create_star_particles(card, particle_pos, Color(0.2, 0.8, 1, 1))

func _create_rare_cards_card():
	var card = _create_base_card()
	card.custom_minimum_size = Vector2(800, 500)
	
	var margin = card.get_child(0)  # MarginContainer criado em _create_base_card
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)
	
	var emoji = Label.new()
	emoji.text = "*"
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji.add_theme_font_size_override("font_size", 100)
	vbox.add_child(emoji)
	
	var label = Label.new()
	label.text = "Cartas Raras Encontradas"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 50)
	var label_settings = LabelSettings.new()
	label_settings.font_size = 50
	label_settings.font_color = Color(1, 1, 1, 1)
	label_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	label.label_settings = label_settings
	vbox.add_child(label)
	
	var counter = Label.new()
	counter.name = "Counter"
	counter.text = "0"
	counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	counter.add_theme_font_size_override("font_size", 120)
	var counter_settings = LabelSettings.new()
	counter_settings.font_size = 120
	counter_settings.font_color = Color(1, 0.843, 0, 1)
	counter_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	counter.label_settings = counter_settings
	vbox.add_child(counter)
	
	var percentage = Label.new()
	var pct = int((float(stats["rare_cards"]) / float(stats["total_cards"])) * 100.0) if stats["total_cards"] > 0 else 0
	percentage.text = str(pct) + "% do total"
	percentage.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	percentage.add_theme_font_size_override("font_size", 40)
	var pct_settings = LabelSettings.new()
	pct_settings.font_size = 40
	pct_settings.font_color = Color(0.8, 0.8, 0.8, 1)
	pct_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	percentage.label_settings = pct_settings
	vbox.add_child(percentage)
	
	cards_container.add_child(card)
	
	# Animar contador
	_animate_counter(counter, 0, stats["rare_cards"], 1.5)
	
	# Efeito especial ao completar
	await get_tree().create_timer(1.6).timeout
	if is_instance_valid(card):
		var confetti_pos = Vector2(card.size.x / 2.0, card.size.y / 2.0)
		ParticlesManager.create_confetti(card, confetti_pos, Color(1, 0.843, 0, 1), 40)

func _create_photos_card():
	var card = _create_base_card()
	card.custom_minimum_size = Vector2(800, 800)
	
	var margin = card.get_child(0)  # MarginContainer criado em _create_base_card
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)
	
	var emoji = Label.new()
	emoji.text = "📸"
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji.add_theme_font_size_override("font_size", 80)
	vbox.add_child(emoji)
	
	var label = Label.new()
	label.text = "Momentos Registrados"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 50)
	var label_settings = LabelSettings.new()
	label_settings.font_size = 50
	label_settings.font_color = Color(1, 1, 1, 1)
	label_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	label.label_settings = label_settings
	vbox.add_child(label)
	
	var counter = Label.new()
	counter.name = "Counter"
	counter.text = "0"
	counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	counter.add_theme_font_size_override("font_size", 80)
	var counter_settings = LabelSettings.new()
	counter_settings.font_size = 80
	counter_settings.font_color = Color(0.2, 0.8, 1, 1)
	counter_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	counter.label_settings = counter_settings
	vbox.add_child(counter)
	
	# Grid de fotos
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 500)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var flow = VBoxContainer.new()
	flow.add_theme_constant_override("separation", 15)
	scroll.add_child(flow)
	vbox.add_child(scroll)
	
	cards_container.add_child(card)
	
	# Animar contador
	_animate_counter(counter, 0, stats["photos_count"], 1.0)
	
	# Carregar fotos com delay
	await get_tree().create_timer(1.2).timeout
	_load_photos_to_grid(flow)

func _load_photos_to_grid(container: VBoxContainer):
	if not is_instance_valid(container):
		return
	
	for i in range(session_photos.size()):
		if not is_instance_valid(container):
			break
		
		var path = session_photos[i]
		var img := Image.new()
		var load_result = img.load(path)
		
		if load_result == OK:
			var tex := ImageTexture.create_from_image(img)
			if tex:
				var spr = TextureRect.new()
				spr.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				spr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				spr.custom_minimum_size = Vector2(0, 400)
				spr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				spr.texture = tex
				spr.modulate.a = 0.0
				container.add_child(spr)
				
				# Fade in sequencial
				var tween = create_tween()
				if tween:
					tween.tween_property(spr, "modulate:a", 1.0, 0.5)
		
		await get_tree().create_timer(0.1).timeout

func _create_play_time_card():
	var card = _create_base_card()
	card.custom_minimum_size = Vector2(800, 500)
	
	var margin = card.get_child(0)  # MarginContainer criado em _create_base_card
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)
	
	var emoji = Label.new()
	emoji.text = "⏰"
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji.add_theme_font_size_override("font_size", 100)
	vbox.add_child(emoji)
	
	var label = Label.new()
	label.text = "Tempo de Jogo"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 50)
	var label_settings = LabelSettings.new()
	label_settings.font_size = 50
	label_settings.font_color = Color(1, 1, 1, 1)
	label_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	label.label_settings = label_settings
	vbox.add_child(label)
	
	var time_label = Label.new()
	time_label.name = "TimeLabel"
	var time_text = ""
	if stats["play_time_hours"] > 0:
		time_text = str(stats["play_time_hours"]) + " hora"
		if stats["play_time_hours"] > 1:
			time_text += "s"
		if stats["play_time_minutes"] > 0:
			time_text += " e " + str(stats["play_time_minutes"]) + " minuto"
			if stats["play_time_minutes"] > 1:
				time_text += "s"
	else:
		time_text = str(stats["play_time_minutes"]) + " minuto"
		if stats["play_time_minutes"] != 1:
			time_text += "s"
	time_label.text = time_text
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.add_theme_font_size_override("font_size", 80)
	var time_settings = LabelSettings.new()
	time_settings.font_size = 80
	time_settings.font_color = Color(0.2, 0.8, 1, 1)
	time_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	time_label.label_settings = time_settings
	vbox.add_child(time_label)
	
	cards_container.add_child(card)
	
	# Animação de entrada
	time_label.modulate.a = 0.0
	var tween = create_tween()
	if tween:
		tween.tween_property(time_label, "modulate:a", 1.0, 1.0)

func _create_top_category_card():
	var card = _create_base_card()
	card.custom_minimum_size = Vector2(800, 500)
	
	var margin = card.get_child(0)  # MarginContainer criado em _create_base_card
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)
	
	var emoji = Label.new()
	emoji.text = "⭐"
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji.add_theme_font_size_override("font_size", 100)
	vbox.add_child(emoji)
	
	var label = Label.new()
	label.text = "Categoria Favorita"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 50)
	var label_settings = LabelSettings.new()
	label_settings.font_size = 50
	label_settings.font_color = Color(1, 1, 1, 1)
	label_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	label.label_settings = label_settings
	vbox.add_child(label)
	
	var category_name = Label.new()
	var cat_display = stats["top_category"].replace("_", " ").capitalize()
	category_name.text = cat_display
	category_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	category_name.add_theme_font_size_override("font_size", 70)
	var cat_settings = LabelSettings.new()
	cat_settings.font_size = 70
	cat_settings.font_color = Color(1, 0.6, 0.2, 1)
	cat_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	category_name.label_settings = cat_settings
	vbox.add_child(category_name)
	
	var count_label = Label.new()
	count_label.text = str(stats["top_category_count"]) + " cartas"
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.add_theme_font_size_override("font_size", 40)
	var count_settings = LabelSettings.new()
	count_settings.font_size = 40
	count_settings.font_color = Color(0.8, 0.8, 0.8, 1)
	count_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	count_label.label_settings = count_settings
	vbox.add_child(count_label)
	
	cards_container.add_child(card)

func _create_final_card():
	var card = _create_base_card()
	card.custom_minimum_size = Vector2(800, 400)
	
	var margin = card.get_child(0)  # MarginContainer criado em _create_base_card
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 30)
	margin.add_child(vbox)
	
	var message = Label.new()
	message.text = "Obrigado por jogar!\nAté a próxima!"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 50)
	var msg_settings = LabelSettings.new()
	msg_settings.font_size = 50
	msg_settings.font_color = Color(1, 1, 1, 1)
	msg_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	message.label_settings = msg_settings
	vbox.add_child(message)
	
	var button = Button.new()
	button.text = "Voltar ao Menu"
	button.custom_minimum_size = Vector2(300, 80)
	button.add_theme_font_size_override("font_size", 40)
	button.pressed.connect(_on_voltar_menu_pressed)
	UIManager.add_button_hover_effect(button)
	vbox.add_child(button)
	
	cards_container.add_child(card)

func _create_base_card() -> Panel:
	var card = Panel.new()
	card.custom_minimum_size = Vector2(800, 500)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# Adicionar margens
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_bottom", 20)
	card.add_child(margin)
	
	# Glassmorphism
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.1)
	style.set_corner_radius_all(30)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1, 0.2)
	card.add_theme_stylebox_override("panel", style)
	
	# Inicialmente invisível para animação
	card.modulate.a = 0.0
	card.scale = Vector2(0.8, 0.8)
	
	return card

func _animate_card_entrance(card: Panel):
	if not is_instance_valid(card) or not card.is_inside_tree():
		return
	
	var tween = create_tween()
	if not tween:
		return
	
	tween.set_parallel(true)
	tween.tween_property(card, "modulate:a", 1.0, 0.6)
	tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.6)
	var start_y = card.position.y - 50
	var end_y = card.position.y
	tween.tween_method(
		func(v): card.position.y = v,
		start_y,
		end_y,
		0.6
	)

func _animate_counter(label: Label, start: int, end: int, duration: float):
	if not is_instance_valid(label) or not label.is_inside_tree():
		return
	
	var tween = create_tween()
	if not tween:
		label.text = str(end)
		return
	
	var current = start
	tween.tween_method(
	func(v):
		if is_instance_valid(label):
			current = int(v)
			label.text = str(current)
	,
	float(start),
	float(end),
	duration
)
	
	# Pulse ao completar
	await tween.finished
	if is_instance_valid(label):
		var pulse_tween = create_tween()
		if pulse_tween:
			pulse_tween.set_loops(2)
			pulse_tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2)
			pulse_tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2)

func _on_voltar_menu_pressed():
	UIManager.change_scene_with_fade("res://Scenes/menu.tscn")
