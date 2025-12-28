extends Control

var pack_state = {
	"leve": true,
	"festeiro": false,
	"relacionamentos": false,
	"ousado": false,
}

@onready var pack_panels = {
	"leve": $MarginContainer/ScrollContainer/HBoxContainer/Leve,
	"festeiro": $MarginContainer/ScrollContainer/HBoxContainer/Festeiro,
	"relacionamentos": $MarginContainer/ScrollContainer/HBoxContainer/Relacionamentos,
	"ousado": $MarginContainer/ScrollContainer/HBoxContainer/Ousado,
}

@onready var counter_label = $PackCounter
@onready var title = $Title
@onready var subtitle = $Subtitle

# Cores dos packs (tons de azul)
const PACK_COLORS = {
	"leve": Color(0.4, 0.75, 1.0, 1.0),
	"festeiro": Color(0.2, 0.5, 0.9, 1.0),
	"relacionamentos": Color(0.6, 0.4, 0.85, 1.0),
	"ousado": Color(0.15, 0.2, 0.45, 1.0),
}

# Variáveis para detectar scroll vs clique
var touch_start_pos: Vector2 = Vector2.ZERO
var touch_start_time: float = 0.0
var is_dragging: bool = false
var drag_threshold: float = 20.0
var mouse_start_pos: Vector2 = Vector2.ZERO
var is_holding: bool = false
var held_pack: String = ""

func _ready():
	for pack_name in pack_state.keys():
		update_pack_visual(pack_name)
	
	_update_counter()
	
	# Conectar botões dos packs
	for pack_name in pack_panels.keys():
		var panel = pack_panels[pack_name]
		var button = panel.get_node("Button")
		if button:
			# Usar gui_input para detectar swipe vs clique (igual ao pack_selector)
			panel.gui_input.connect(func(event): _on_pack_gui_input(event, pack_name))
	
	# Adicionar hover effects
	UIManager.add_button_hover_effect($Voltar)
	UIManager.add_button_hover_effect($Começar)
	
	# Adicionar partículas
	ParticlesManager.create_bubble_particles(self)
	
	# Atualizar textos traduzidos
	_update_ui_texts()
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)

func _update_ui_texts():
	if title:
		title.text = LocalizationManager.translate("never_title", "EU NUNCA")
	if subtitle:
		subtitle.text = LocalizationManager.translate("never_subtitle", "Selecione as categorias e descubra quem já fez o quê!")
	if has_node("SwipeHint"):
		$SwipeHint.text = LocalizationManager.translate("never_swipe_hint", "Deslize para escolher seus packs.")
	
	# Textos dos packs
	_update_pack_text("leve", "never_pack_leve", "LEVE", "never_pack_leve_desc", "Perguntas inocentes para qualquer grupo")
	_update_pack_text("festeiro", "never_pack_festeiro", "FESTEIRO", "never_pack_festeiro_desc", "Sobre festas, bebidas e curtição")
	_update_pack_text("relacionamentos", "never_pack_romance", "ROMANCE", "never_pack_romance_desc", "Crushes, namoro e relacionamentos")
	_update_pack_text("ousado", "never_pack_ousado", "OUSADO", "never_pack_ousado_desc", "+18 picante")
	
	# Botões
	$Voltar.text = LocalizationManager.translate("never_back", "Voltar")
	$Começar.text = LocalizationManager.translate("never_start", "Começar")
	
	_update_counter()

func _update_pack_text(pack_name: String, name_key: String, name_default: String, desc_key: String, desc_default: String):
	if not pack_panels.has(pack_name):
		return
	var panel = pack_panels[pack_name]
	var name_label = panel.get_node("name")
	var desc_label = panel.get_node("description")
	if name_label:
		name_label.text = LocalizationManager.translate(name_key, name_default)
	if desc_label:
		desc_label.text = LocalizationManager.translate(desc_key, desc_default)

func update_pack_visual(pack_name: String):
	if not pack_panels.has(pack_name):
		return
	var panel = pack_panels[pack_name]
	var is_active = pack_state[pack_name]
	
	# Opacidade
	panel.modulate = Color(1,1,1,1) if is_active else Color(1,1,1,0.5)
	
	# Borda brilhante
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
		if panel:
			panel.scale = Vector2.ONE
		return
	var tween = panel.get_meta("_pulse_tween")
	if tween and tween is Tween:
		tween.kill()
	panel.remove_meta("_pulse_tween")
	panel.scale = Vector2.ONE

func _on_pack_gui_input(event: InputEvent, pack_name: String):
	if event is InputEventScreenTouch:
		if event.pressed:
			is_holding = true
			held_pack = pack_name
			touch_start_pos = event.position
			touch_start_time = Time.get_ticks_msec()
			is_dragging = false
		else:
			var touch_end_pos = event.position
			var distance = touch_start_pos.distance_to(touch_end_pos)
			var time_elapsed = Time.get_ticks_msec() - touch_start_time
			
			if distance < drag_threshold and time_elapsed < 300 and not is_dragging:
				if pack_panels.has(pack_name):
					_on_pack_panel_pressed(pack_name)
			
			is_holding = false
			held_pack = ""
			is_dragging = false
	elif event is InputEventScreenDrag:
		if abs(event.relative.x) > drag_threshold or abs(event.relative.y) > drag_threshold:
			is_dragging = true
	elif event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
			
		if event.pressed:
			is_holding = true
			held_pack = pack_name
			mouse_start_pos = event.position
			is_dragging = false
		else:
			var mouse_end_pos = event.position
			var mouse_distance = mouse_start_pos.distance_to(mouse_end_pos)
			
			if mouse_distance < drag_threshold:
				if pack_panels.has(pack_name):
					_on_pack_panel_pressed(pack_name)
			
			is_holding = false
			held_pack = ""
			is_dragging = false
	elif event is InputEventMouseMotion:
		if is_holding:
			var relative_movement = event.relative.length()
			if relative_movement > drag_threshold:
				is_dragging = true
			var current_distance = mouse_start_pos.distance_to(event.position)
			if current_distance > drag_threshold:
				is_dragging = true

func _on_pack_panel_pressed(pack_name: String):
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
		var color = PACK_COLORS.get(pack_name, Color.WHITE)
		ParticlesManager.create_pulse_particles(self, panel.global_position + panel.size / 2, color)
	
	update_pack_visual(pack_name)
	_update_counter()

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
	
	# Mudar cor baseado em quantidade (tons de azul)
	if count == 0:
		counter_label.modulate = Color(0.9, 0.1, 0.1, 1)
	elif count <= 2:
		counter_label.modulate = Color(0.4, 0.7, 1.0, 1)
	else:
		counter_label.modulate = Color(0.2, 1, 0.6, 1)

func _on_leve_pressed() -> void:
	_on_pack_panel_pressed("leve")

func _on_festeiro_pressed() -> void:
	_on_pack_panel_pressed("festeiro")

func _on_relacionamentos_pressed() -> void:
	_on_pack_panel_pressed("relacionamentos")

func _on_ousado_pressed() -> void:
	_on_pack_panel_pressed("ousado")

func _on_voltar_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/game_hub.tscn")

func _on_começar_pressed() -> void:
	# Validar se pelo menos um pack está selecionado
	var has_selected_pack = false
	for pack_name in pack_state.keys():
		if pack_state[pack_name]:
			has_selected_pack = true
			break
	
	if not has_selected_pack:
		_show_error_message(LocalizationManager.translate("never_error", "Selecione pelo menos 1 pack para começar!"))
		return
	
	# Ir para o jogo
	var packed_scene = load("res://Scenes/never_have_i_ever_game.tscn")
	var next_scene = packed_scene.instantiate()
	next_scene.pack_state = pack_state
	
	var current = get_tree().current_scene
	get_tree().root.add_child(next_scene)
	get_tree().set_current_scene(next_scene)
	if current and is_instance_valid(current):
		current.queue_free()

func _show_error_message(message: String) -> void:
	var error_label = Label.new()
	error_label.text = message
	
	var settings = LabelSettings.new()
	settings.font_size = 40
	settings.font_color = Color(1, 0.3, 0.3, 1)
	settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	error_label.label_settings = settings
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	error_label.position = Vector2(100, 1350)
	error_label.size = Vector2(880, 100)
	
	add_child(error_label)
	
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(error_label):
		error_label.queue_free()
