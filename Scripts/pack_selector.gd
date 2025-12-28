extends Control

var pack_state = {
	"classico": true,
	"nonsense": false,
	"weirdo": false,
	"languages": false,
	"pool": false,
	"spicy": false,
}
@onready var pack_panels = {
	"classico": $MarginContainer/ScrollContainer/HBoxContainer/Classic,
	"nonsense": $MarginContainer/ScrollContainer/HBoxContainer/NonSense,
	"weirdo": $MarginContainer/ScrollContainer/HBoxContainer/Weirdo,
	"languages": $MarginContainer/ScrollContainer/HBoxContainer/Languages,
	"pool": $MarginContainer/ScrollContainer/HBoxContainer/Pool,
	"spicy": $MarginContainer/ScrollContainer/HBoxContainer/Spicy
}
var custom_packs: Array = []
@onready var hbox: HBoxContainer = $MarginContainer/ScrollContainer/HBoxContainer
@onready var counter_label = $PackCounter

# Preview
var preview_popup: Control = null
var hold_timer: float = 0.0
var is_holding: bool = false
var held_pack: String = ""

# Exemplos de cartas por pack (para preview)
var pack_examples = {
	"classico": ["Todos os homens bebem", "O mais alto da roda, bebe", "Conte uma piada"],
	"nonsense": ["Fique encarando alguém sem rir", "Ande em câmera lenta", "Imite um telefone antigo"],
	"weirdo": ["Mindinho no nariz por 3 rodadas", "Faça um discurso sobre baratas", "Fique como estátua"],
	"languages": ["Cante em chinês", "Recite alfabeto ao contrário", "Fale em rimas"],
	"pool": ["Quem é mais mentiroso?", "Quem bebe mais?", "Quem casa primeiro?"],
	"spicy": ["Deixe um chupão", "Conte um segredo íntimo", "Troque de roupa"]
}

func _ready():
	for pack_name in pack_state.keys():
		update_pack_visual(pack_name)
	_load_custom_packs()
	_update_counter()
	
	# Atualizar textos traduzidos
	_update_ui_texts()
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)
	
	# Adicionar hover effects nos botões
	UIManager.add_button_hover_effect($Button)
	UIManager.add_button_hover_effect($Começar)
	UIManager.add_button_hover_effect($CriarPack)
	
	# Adicionar gui_input listeners para preview
	for pack_name in pack_panels.keys():
		var panel = pack_panels[pack_name]
		panel.gui_input.connect(func(event): _on_pack_gui_input(event, pack_name))
	
	# Animação do botão criar pack removida

func _update_ui_texts():
	# Atualizar nomes e descrições dos packs
	if pack_panels.has("classico"):
		var panel = pack_panels["classico"]
		if panel.has_node("name"):
			panel.get_node("name").text = LocalizationManager.translate("pack_classic", "Clássico")
		if panel.has_node("description"):
			panel.get_node("description").text = LocalizationManager.translate("pack_classic_description", "Clássico é classico, ne? Para todos os gostos.")
	
	if pack_panels.has("nonsense"):
		var panel = pack_panels["nonsense"]
		if panel.has_node("Label"):
			panel.get_node("Label").text = LocalizationManager.translate("pack_nonsense", "Non-Sense")
		if panel.has_node("description"):
			panel.get_node("description").text = LocalizationManager.translate("pack_nonsense_description", "Auto-explicativo né? Se prepara pra ver seu amigo imitando uma girafa servindo chá na russia.")
	
	if pack_panels.has("weirdo"):
		var panel = pack_panels["weirdo"]
		if panel.has_node("Label"):
			panel.get_node("Label").text = LocalizationManager.translate("pack_weirdo", "Weirdo")
		if panel.has_node("description"):
			panel.get_node("description").text = LocalizationManager.translate("pack_weirdo_description", "Pra quem gosta de agir como estranhão.")
	
	if pack_panels.has("languages"):
		var panel = pack_panels["languages"]
		if panel.has_node("Label"):
			panel.get_node("Label").text = LocalizationManager.translate("pack_languages", "Idiomas")
		if panel.has_node("description"):
			panel.get_node("description").text = LocalizationManager.translate("pack_languages_description", "Pros seus amigos que se acham políglotas.")
	
	if pack_panels.has("pool"):
		var panel = pack_panels["pool"]
		if panel.has_node("Label"):
			panel.get_node("Label").text = LocalizationManager.translate("pack_pool", "Votação")
		if panel.has_node("description"):
			panel.get_node("description").text = LocalizationManager.translate("pack_pool_description", "Quem do grupo é mais isso? Quem faz mais aquilo? O mais votado, bebe :)")
	
	if pack_panels.has("spicy"):
		var panel = pack_panels["spicy"]
		if panel.has_node("Label"):
			panel.get_node("Label").text = LocalizationManager.translate("pack_spicy", "Spicy")
		if panel.has_node("description"):
			panel.get_node("description").text = LocalizationManager.translate("pack_spicy_description", "+18")
	
	# Atualizar textos da UI
	if has_node("Label"):
		$Label.text = LocalizationManager.translate("pack_selector_title", "Selecione seus packs")
	if has_node("Label2"):
		$Label2.text = LocalizationManager.translate("pack_selector_subtitle", "Selecione packs feito por nós, ou crie o seu próprio! Misture os packs como desejar!")
	if has_node("Label2/Label2"):
		$Label2/Label2.text = LocalizationManager.translate("pack_selector_swipe_hint", "Deslize para escolher seus packs.")
	if has_node("Button"):
		$Button.text = LocalizationManager.translate("pack_selector_back", "Voltar")
	if has_node("CriarPack"):
		$CriarPack.text = LocalizationManager.translate("pack_selector_create_pack", "Criar PACK +")
	if has_node("Começar"):
		$Começar.text = LocalizationManager.translate("pack_selector_start", "Começar")
	
	_update_counter()
	
func update_pack_visual(pack_name):
	var panel = pack_panels[pack_name]
	var is_active = pack_state[pack_name]
	
	# Opacidade
	panel.modulate = Color(1,1,1,1) if is_active else Color(1,1,1,0.5)
	
	# Adicionar/remover borda brilhante
	var style = panel.get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		if is_active:
			style.shadow_size = 15
			style.shadow_color = Color(1, 1, 1, 0.5)
			style.border_width_left = 4
			style.border_width_right = 4
			style.border_width_top = 4
			style.border_width_bottom = 4
			style.border_color = Color(1, 1, 1, 0.8)
			_pulse_glow(panel)
		else:
			style.shadow_size = 0
			style.border_width_left = 0
			style.border_width_right = 0
			style.border_width_top = 0
			style.border_width_bottom = 0
			_stop_pulse(panel)
	else:
		_stop_pulse(panel)

func _pulse_glow(panel: Control):
	if not panel or not is_instance_valid(panel) or not panel.is_inside_tree():
		return
	_stop_pulse(panel)
	var tween = panel.create_tween()
	if not tween:
		return
	tween.set_loops()
	tween.tween_property(panel, "scale", Vector2(1.02, 1.02), 1.0)
	tween.tween_property(panel, "scale", Vector2.ONE, 1.0)
	panel.set_meta("_pulse_tween", tween)

func _stop_pulse(panel: Control) -> void:
	if not panel or not panel.has_meta("_pulse_tween"):
		panel.scale = Vector2.ONE
		return
	var tween = panel.get_meta("_pulse_tween")
	if tween and tween is Tween:
		tween.kill()
	panel.remove_meta("_pulse_tween")
	panel.scale = Vector2.ONE

func _on_pack_panel_pressed(pack_name):
	pack_state[pack_name] = !pack_state[pack_name]
	
	# Animação ao selecionar
	var panel = pack_panels[pack_name]
	if not is_instance_valid(panel) or not panel.is_inside_tree():
		return
	var tween = panel.create_tween()
	if not tween:
		return
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(panel, "rotation_degrees", 5, 0.1)
	tween.chain().tween_property(panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "rotation_degrees", 0, 0.2).set_trans(Tween.TRANS_BACK)
	
	# Vibrar
	UIManager.safe_vibrate(50)
	
	# Partículas
	if pack_state[pack_name]:
		var color = _get_pack_color(pack_name)
		ParticlesManager.create_pulse_particles(self, panel.global_position + panel.size / 2, color)
	
	update_pack_visual(pack_name)
	_update_counter()

func _get_pack_color(pack_name: String) -> Color:
	match pack_name:
		"classico": return Color(1, 1, 1, 1)
		"nonsense": return Color(1, 0.392, 0.624, 1)
		"weirdo": return Color(0.351, 0.946, 0.858, 1)
		"languages": return Color(0.989, 0.667, 0.411, 1)
		"pool": return Color(0.688, 0.214, 0.901, 1)
		"spicy": return Color(1, 0.13, 0.231, 1)
	return Color.WHITE

func _update_counter():
	if not counter_label:
		return
	
	var count = 0
	for pack_name in pack_state.keys():
		if pack_state[pack_name]:
			count += 1
	
	if count == 1:
		counter_label.text = LocalizationManager.translate("pack_counter_singular", "1 pack selecionado")
	else:
		counter_label.text = LocalizationManager.translate("pack_counter_plural", "%d packs selecionados") % count
	
	# Animar contador
	UIManager.pulse_element(counter_label, 1.3, 0.3)
	
	# Mudar cor baseado em quantidade
	if count == 0:
		counter_label.modulate = Color(0.9, 0.1, 0.1, 1)
	elif count <= 2:
		counter_label.modulate = Color(1, 0.7, 0.2, 1)
	else:
		counter_label.modulate = Color(0.2, 1, 0.2, 1)

func _on_classic_pressed() -> void:
	_on_pack_panel_pressed("classico")
	
func _on_nonsense_pressed() -> void:
	_on_pack_panel_pressed("nonsense")
	
func _on_weirdo_pressed() -> void:
	_on_pack_panel_pressed("weirdo")

func _on_languages_pressed() -> void:
	_on_pack_panel_pressed("languages")
	
func _on_pool_pressed() -> void:
	_on_pack_panel_pressed("pool")
	
func _on_spicy_pressed() -> void:
	_on_pack_panel_pressed("spicy")

func _on_button_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/menu.tscn")
	
func _process(delta: float) -> void:
	# Preview ao segurar pack
	if is_holding:
		hold_timer += delta
		if hold_timer >= 0.5 and preview_popup == null:
			_show_preview(held_pack)

# Variáveis para detectar scroll vs clique
var touch_start_pos: Vector2 = Vector2.ZERO
var touch_start_time: float = 0.0
var is_dragging: bool = false
var drag_threshold: float = 20.0  # Pixels de movimento para considerar arrasto (aumentado para evitar falsos positivos)
var mouse_start_pos: Vector2 = Vector2.ZERO  # Posição inicial do mouse para detectar arrasto

func _on_pack_gui_input(event: InputEvent, pack_name: String):
	# Com MOUSE_FILTER_IGNORE, este evento só é chamado se algo dentro do panel capturar
	# Vamos usar uma área invisível para detectar cliques sem bloquear arrastos
	if event is InputEventScreenTouch:
		if event.pressed:
			is_holding = true
			held_pack = pack_name
			hold_timer = 0.0
			touch_start_pos = event.position
			touch_start_time = Time.get_ticks_msec()
			is_dragging = false
		else:
			# Verificar se foi arrasto ou clique
			var touch_end_pos = event.position
			var distance = touch_start_pos.distance_to(touch_end_pos)
			var time_elapsed = Time.get_ticks_msec() - touch_start_time
			
			# Se moveu pouco e rápido, é um clique
			if distance < drag_threshold and time_elapsed < 300 and not is_dragging:
				# É um clique - processar seleção
				if pack_panels.has(pack_name):
					_on_pack_panel_pressed(pack_name)
			
			is_holding = false
			held_pack = ""
			hold_timer = 0.0
			is_dragging = false
			if preview_popup:
				_hide_preview()
	elif event is InputEventScreenDrag:
		# Se está arrastando, marcar como drag (não é clique)
		if abs(event.relative.x) > drag_threshold or abs(event.relative.y) > drag_threshold:
			is_dragging = true
			# IMPORTANTE: Passar evento para o ScrollContainer manualmente
			# Criar novo evento e enviar para o ScrollContainer
			var scroll_container = get_node_or_null("MarginContainer/ScrollContainer")
			if scroll_container and scroll_container is ScrollContainer:
				# Não processar - deixar ScrollContainer receber
				# O ScrollContainer precisa receber o evento diretamente
				# Como já capturamos, vamos apenas não fazer nada e deixar o evento passar
				pass  # Não processar arrastos
	elif event is InputEventMouseButton:
		# Para mouse (desktop), processar normalmente
		# IMPORTANTE: Só processar botão esquerdo, ignorar scroll
		if event.button_index != MOUSE_BUTTON_LEFT:
			return  # Ignorar scroll do mouse e outros botões
			
		if event.pressed:
			is_holding = true
			held_pack = pack_name
			hold_timer = 0.0
			mouse_start_pos = event.position  # Guardar posição inicial
			is_dragging = false  # Resetar flag de arrasto
		else:
			# Quando solta o botão, verificar se foi clique ou arrasto
			var mouse_end_pos = event.position
			var mouse_distance = mouse_start_pos.distance_to(mouse_end_pos)
			
			# CORRIGIDO: Processar como clique se a distância for pequena
			# Se moveu pouco (< drag_threshold), é um CLIQUE - selecionar
			# Se moveu muito (>= drag_threshold), é um ARRASTO - não selecionar
			# Usar apenas a distância, não depender de is_dragging (pode ter falsos positivos)
			if mouse_distance < drag_threshold:
				# É um clique simples - selecionar o pack
				if pack_panels.has(pack_name):
					_on_pack_panel_pressed(pack_name)
			# Se moveu muito (>= drag_threshold), não fazer nada (deixar ScrollContainer processar o scroll)
			
			# Resetar tudo
			is_holding = false
			held_pack = ""
			hold_timer = 0.0
			is_dragging = false
			if preview_popup:
				_hide_preview()
	elif event is InputEventMouseMotion:
		# Para mouse, detectar arrasto APENAS se estiver segurando o botão
		# IMPORTANTE: Só marcar como arrasto se o movimento for REALMENTE significativo
		if is_holding:
			# Verificar movimento relativo (mais confiável)
			var relative_movement = event.relative.length()
			# Só marcar como arrasto se o movimento for significativo
			if relative_movement > drag_threshold:
				is_dragging = true
			# Também verificar distância total da posição inicial
			var current_distance = mouse_start_pos.distance_to(event.position)
			if current_distance > drag_threshold:
				is_dragging = true

func _show_preview(pack_name: String):
	if not pack_examples.has(pack_name):
		return
	
	# Vibrar
	UIManager.safe_vibrate(100)
	
	# Criar popup
	preview_popup = UIManager.create_glassmorphism_panel(
		Vector2(800, 500),
		Vector2(140, 710),
		Color(0, 0, 0, 0.9)
	)
	preview_popup.z_index = 300
	add_child(preview_popup)
	
	var vbox = VBoxContainer.new()
	vbox.size = preview_popup.size
	vbox.add_theme_constant_override("separation", 20)
	preview_popup.add_child(vbox)
	
	# Título
	var title = Label.new()
	title.text = "Preview - " + pack_name.capitalize()
	var title_settings = LabelSettings.new()
	title_settings.font_size = 40
	title_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	title.label_settings = title_settings
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Exemplos de cartas
	for example in pack_examples[pack_name]:
		var card_label = Label.new()
		card_label.text = "• " + example
		var card_settings = LabelSettings.new()
		card_settings.font_size = 28
		card_label.label_settings = card_settings
		card_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card_label.custom_minimum_size.x = 750
		vbox.add_child(card_label)
	
	# Animar entrada
	UIManager.animate_panel_entrance(preview_popup)

func _hide_preview():
	if preview_popup and is_instance_valid(preview_popup) and preview_popup.is_inside_tree():
		var tween = create_tween()
		if tween:
			tween.tween_property(preview_popup, "modulate:a", 0.0, 0.3)
			await tween.finished
		if is_instance_valid(preview_popup):
			preview_popup.queue_free()
		preview_popup = null

func _on_começar_pressed() -> void:
	# Validar se pelo menos um pack está selecionado
	var has_selected_pack = false
	for pack_name in pack_state.keys():
		if pack_state[pack_name]:
			has_selected_pack = true
			break
	
	if not has_selected_pack:
		# Mostrar mensagem de erro
		show_error_message(LocalizationManager.translate("pack_selector_error", "Selecione pelo menos 1 pack para começar!"))
		return
	
	# Carrega a cena do seletor de modos
	var packed_scene = load("res://Scenes/mode_selector.tscn")
	var next_scene = packed_scene.instantiate()

	# Passa o estado dos pacotes para a nova cena
	next_scene.pack_state = pack_state

	# Muda para a nova cena
	var current = get_tree().current_scene
	get_tree().root.add_child(next_scene)
	get_tree().set_current_scene(next_scene)
	if current and is_instance_valid(current):
		current.queue_free()

func show_error_message(message: String) -> void:
	# Criar label temporário para mostrar erro
	var error_label = Label.new()
	error_label.text = message
	
	var settings = LabelSettings.new()
	settings.font_size = 40
	settings.font_color = Color("e5193f")
	settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	error_label.label_settings = settings
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Posicionar no centro da tela
	error_label.position = Vector2(100, 1350)
	error_label.size = Vector2(880, 100)
	
	add_child(error_label)
	
	# Remover após 3 segundos
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(error_label):
		error_label.queue_free()

func _load_custom_packs():
	var file_path = "user://custom_packs.json"
	if not FileAccess.file_exists(file_path):
		return
	var f = FileAccess.open(file_path, FileAccess.READ)
	if not f:
		return
	var txt = f.get_as_text()
	f.close()
	var data = JSON.parse_string(txt)
	if typeof(data) == TYPE_DICTIONARY and data.has("packs"):
		custom_packs = data.packs
		for p in custom_packs:
			_add_custom_pack_panel(p)

func _add_custom_pack_panel(pack: Dictionary):
	var id: String = "custom_" + (pack.get("name", "Pack") as String)
	pack_state[id] = false
	
	# Criar Panel exatamente como os hardcoded
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(380, 0)
	panel.layout_mode = 2  # SIZE_EXPAND_FILL
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Mesmo que hardcoded (mouse_filter = 2)
	panel.clip_contents = false
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(pack.get("color", "#888888"))
	style.set_corner_radius_all(95)
	style.corner_detail = 20
	panel.add_theme_stylebox_override("panel", style)
	hbox.add_child(panel)
	
	# Label do nome posicionado no topo (igual aos hardcoded)
	var name_label = Label.new()
	name_label.name = "name"
	name_label.text = pack.get("name", "Pack")
	name_label.layout_mode = 1
	name_label.anchors_preset = Control.PRESET_CENTER_TOP
	name_label.anchor_left = 0.5
	name_label.anchor_right = 0.5
	name_label.offset_left = -92.5
	name_label.offset_right = 92.5
	name_label.offset_bottom = 67.0
	name_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	var ls = LabelSettings.new()
	ls.font_size = 48
	ls.font_color = Color(0, 0, 0, 1)
	name_label.label_settings = ls
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(name_label)
	
	# Button interno - EXATAMENTE como os hardcoded para funcionar igual
	var btn = Button.new()
	btn.name = "button"
	btn.show_behind_parent = true
	btn.layout_mode = 1
	btn.anchors_preset = Control.PRESET_FULL_RECT
	btn.anchor_right = 1.0
	btn.anchor_bottom = 1.0
	btn.grow_horizontal = Control.GROW_DIRECTION_BOTH
	btn.grow_vertical = Control.GROW_DIRECTION_BOTH
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_filter = Control.MOUSE_FILTER_PASS  # PASS (1) para permitir scroll - igual hardcoded
	btn.flat = true
	panel.add_child(btn)
	
	# Conectar o botão para selecionar o pack
	btn.pressed.connect(func(): _on_custom_pressed(id))
	
	# Ícone SVG centralizado
	var icon = TextureRect.new()
	icon.texture = load("res://icons/customized.svg")
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Permite cliques passarem para o botão
	icon.layout_mode = 1
	icon.anchors_preset = Control.PRESET_CENTER
	icon.anchor_left = 0.5
	icon.anchor_top = 0.5
	icon.anchor_right = 0.5
	icon.anchor_bottom = 0.5
	icon.offset_left = -80
	icon.offset_top = -80
	icon.offset_right = 80
	icon.offset_bottom = 80
	icon.grow_horizontal = Control.GROW_DIRECTION_BOTH
	icon.grow_vertical = Control.GROW_DIRECTION_BOTH
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel.add_child(icon)
	
	# Descrição (número de cartas)
	var desc_label = Label.new()
	desc_label.name = "description"
	var card_count = pack.get("cards", []).size()
	if card_count == 1:
		desc_label.text = LocalizationManager.translate("custom_pack_card_singular", "%d carta") % card_count
	else:
		desc_label.text = LocalizationManager.translate("custom_pack_card_plural", "%d cartas") % card_count
	desc_label.layout_mode = 1
	desc_label.anchors_preset = Control.PRESET_CENTER_TOP
	desc_label.anchor_left = 0.5
	desc_label.anchor_right = 0.5
	desc_label.offset_left = -187.0
	desc_label.offset_top = 530.0
	desc_label.offset_right = 187.0
	desc_label.offset_bottom = 583.0
	desc_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	var desc_ls = LabelSettings.new()
	desc_ls.font_size = 23
	desc_ls.font_color = Color(1, 1, 1, 1)
	desc_label.label_settings = desc_ls
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(desc_label)
	
	# Adicionar ao dicionário para poder aplicar efeitos visuais
	pack_panels[id] = panel
	
	# Conectar gui_input no panel para preview (segurar)
	panel.gui_input.connect(func(event): _on_pack_gui_input(event, id))
	
	# Adicionar ao pack_examples para preview
	var cards = pack.get("cards", [])
	if cards.size() > 0:
		var preview_cards = []
		for i in range(min(3, cards.size())):
			preview_cards.append(cards[i])
		pack_examples[id] = preview_cards
	
	# Aplicar efeitos visuais iniciais
	_update_custom_pack_visual(id)

func _on_custom_pressed(id: String):
	pack_state[id] = !pack_state[id]
	
	# Animação ao selecionar
	var panel = pack_panels[id]
	if not is_instance_valid(panel) or not panel.is_inside_tree():
		return
	var tween = create_tween()
	if not tween:
		return
	tween.set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(panel, "rotation_degrees", 5, 0.1)
	tween.chain().tween_property(panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "rotation_degrees", 0, 0.2).set_trans(Tween.TRANS_BACK)
	
	# Vibrar
	UIManager.safe_vibrate(50)
	
	# Partículas
	if pack_state[id]:
		var color = _get_custom_pack_color(id)
		ParticlesManager.create_pulse_particles(self, panel.global_position + panel.size / 2, color)
	
	_update_custom_pack_visual(id)
	_update_counter()

func _get_custom_pack_color(id: String) -> Color:
	# Pegar cor do pack customizado do array custom_packs
	for pack in custom_packs:
		var pack_id = "custom_" + (pack.get("name", "Pack") as String)
		if pack_id == id:
			return Color(pack.get("color", "#888888"))
	return Color.WHITE

func _update_custom_pack_visual(id: String):
	if not pack_panels.has(id):
		return
	
	var panel = pack_panels[id]
	var is_active = pack_state[id]
	
	# Opacidade
	panel.modulate = Color(1,1,1,1) if is_active else Color(1,1,1,0.5)
	
	# Adicionar/remover borda brilhante e sombra
	var style = panel.get_theme_stylebox("panel")
	if style is StyleBoxFlat:
		if is_active:
			style.shadow_size = 15
			style.shadow_color = Color(1, 1, 1, 0.5)
			style.border_width_left = 4
			style.border_width_right = 4
			style.border_width_top = 4
			style.border_width_bottom = 4
			style.border_color = Color(1, 1, 1, 0.8)
			_pulse_glow(panel)
		else:
			style.shadow_size = 0
			style.border_width_left = 0
			style.border_width_right = 0
			style.border_width_top = 0
			style.border_width_bottom = 0

func _animate_create_button():
	# Animação removida - botão não anima mais
	# Garantir que qualquer tween anterior seja removido
	var button = $CriarPack
	if button and is_instance_valid(button) and button.is_inside_tree():
		if button.has_meta("_pulse_tween"):
			var existing = button.get_meta("_pulse_tween")
			if existing and existing is Tween and is_instance_valid(existing):
				existing.kill()
			button.remove_meta("_pulse_tween")
		# Garantir que o botão está no tamanho normal
		if is_instance_valid(button):
			button.scale = Vector2.ONE

func _on_criar_pack_pressed():
	UIManager.change_scene_with_fade("res://Scenes/custom_pack_editor.tscn")
