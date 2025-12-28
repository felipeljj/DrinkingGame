extends Node

# Singleton para gerenciar transições e efeitos UI globais

var _fade_layer: CanvasLayer
var _fade_rect: ColorRect

# Configurações
var vibration_enabled: bool = true
var debug_menu_active: bool = false
var debug_button: Button = null
var fps_label: Label = null

# Novas configurações
var allow_card_repeat: bool = false
var font_size_multiplier: float = 1.0

# Constantes para tamanhos de fonte
const FONT_SIZE_SMALL: float = 0.8
const FONT_SIZE_NORMAL: float = 1.0
const FONT_SIZE_LARGE: float = 1.2
const FONT_SIZE_EXTRA_LARGE: float = 1.4

func _ready() -> void:
	_ensure_fade_overlay()
	# Carregar configurações salvas
	_load_settings()

func _process(_delta: float):
	# Verificar se o botão debug precisa ser recriado (se estava ativo mas não existe)
	if debug_menu_active:
		if not debug_button or not is_instance_valid(debug_button):
			_create_debug_button()
		# Atualizar FPS
		if fps_label and is_instance_valid(fps_label):
			fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		vibration_enabled = config.get_value("settings", "vibration_enabled", true)
		debug_menu_active = config.get_value("settings", "debug_menu_active", false)
		allow_card_repeat = config.get_value("settings", "allow_card_repeat", false)
		font_size_multiplier = config.get_value("settings", "font_size_multiplier", 1.0)
	else:
		# Criar arquivo padrão
		_save_settings()
	
	# Recriar botão debug se estava ativo
	if debug_menu_active:
		call_deferred("_create_debug_button")

func _save_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		config = ConfigFile.new()
	
	config.set_value("settings", "vibration_enabled", vibration_enabled)
	config.set_value("settings", "debug_menu_active", debug_menu_active)
	config.set_value("settings", "allow_card_repeat", allow_card_repeat)
	config.set_value("settings", "font_size_multiplier", font_size_multiplier)
	config.save("user://settings.cfg")

func is_vibration_enabled() -> bool:
	return vibration_enabled

func set_vibration_enabled(enabled: bool):
	vibration_enabled = enabled
	_save_settings()

# Métodos para repetir cartas
func is_card_repeat_allowed() -> bool:
	return allow_card_repeat

func set_allow_card_repeat(enabled: bool):
	allow_card_repeat = enabled
	_save_settings()

# Métodos para tamanho de fonte
func get_font_size_multiplier() -> float:
	return font_size_multiplier

func set_font_size(multiplier: float):
	font_size_multiplier = multiplier
	_save_settings()

# Métodos para idioma (delegar para LocalizationManager)
func get_language() -> String:
	if LocalizationManager:
		return LocalizationManager.get_language()
	return "pt"

func set_language(lang: String):
	if LocalizationManager:
		LocalizationManager.set_language(lang)

func toggle_debug_menu():
	debug_menu_active = not debug_menu_active
	_save_settings()  # Salvar estado
	if debug_menu_active:
		_create_debug_button()
	else:
		_remove_debug_button()

func _create_debug_button():
	# Remover botão antigo se existir
	if debug_button and is_instance_valid(debug_button):
		debug_button.queue_free()
		debug_button = null
	
	# Remover FPS label antigo se existir
	if fps_label and is_instance_valid(fps_label):
		fps_label.queue_free()
		fps_label = null
	
	var root = get_tree().root
	if not root:
		return
	
	# Criar botão debug
	debug_button = Button.new()
	debug_button.text = "🐛 DEBUG"
	debug_button.custom_minimum_size = Vector2(150, 80)
	debug_button.position = Vector2(20, 20)
	debug_button.z_index = 1000
	debug_button.add_theme_font_size_override("font_size", 35)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.6, 0.2, 0.9)
	style.set_corner_radius_all(10)
	style.border_color = Color(0, 1, 0, 1)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	debug_button.add_theme_stylebox_override("normal", style)
	debug_button.add_theme_stylebox_override("hover", style)
	debug_button.add_theme_stylebox_override("pressed", style)
	
	debug_button.pressed.connect(_on_debug_button_pressed)
	root.add_child(debug_button)
	
	UIManager.add_button_hover_effect(debug_button)
	
	# Criar label de FPS
	fps_label = Label.new()
	fps_label.text = "FPS: 60"
	fps_label.position = Vector2(20, 110)
	fps_label.z_index = 1000
	fps_label.add_theme_font_size_override("font_size", 30)
	
	var fps_style = StyleBoxFlat.new()
	fps_style.bg_color = Color(0, 0, 0, 0.7)
	fps_style.set_corner_radius_all(5)
	fps_label.add_theme_stylebox_override("normal", fps_style)
	
	var fps_settings = LabelSettings.new()
	fps_settings.font_size = 30
	fps_settings.font_color = Color(0, 1, 0, 1)
	fps_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	fps_label.label_settings = fps_settings
	
	root.add_child(fps_label)

func _remove_debug_button():
	if debug_button and is_instance_valid(debug_button):
		debug_button.queue_free()
		debug_button = null
	if fps_label and is_instance_valid(fps_label):
		fps_label.queue_free()
		fps_label = null

func _on_debug_button_pressed():
	_show_debug_menu()

func _show_debug_menu():
	var root = get_tree().root
	if not root:
		return
	
	# Criar modal de fundo
	var modal_bg = ColorRect.new()
	modal_bg.color = Color(0, 0, 0, 0.7)
	modal_bg.size = get_viewport().size
	modal_bg.z_index = 1500
	modal_bg.name = "DebugModalBG"
	root.add_child(modal_bg)
	
	# Painel de debug
	var debug_panel = Panel.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	panel_style.set_corner_radius_all(25)
	panel_style.border_color = Color(0, 1, 0, 0.8)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	debug_panel.add_theme_stylebox_override("panel", panel_style)
	debug_panel.custom_minimum_size = Vector2(600, 600)
	debug_panel.position = Vector2(164, 690)
	debug_panel.z_index = 1501
	debug_panel.name = "DebugPanel"
	root.add_child(debug_panel)
	
	# Fechar ao clicar no fundo
	var bg_ref = weakref(modal_bg)
	var panel_ref = weakref(debug_panel)
	modal_bg.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var bg = bg_ref.get_ref()
			var panel = panel_ref.get_ref()
			if bg and is_instance_valid(bg):
				bg.queue_free()
			if panel and is_instance_valid(panel):
				panel.queue_free()
	)
	
	# Container vertical
	var vbox = VBoxContainer.new()
	vbox.size = debug_panel.size
	vbox.add_theme_constant_override("separation", 20)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	debug_panel.add_child(vbox)
	
	# Título
	var title = Label.new()
	title.text = "DEBUG MENU"
	var title_settings = LabelSettings.new()
	title_settings.font_size = 50
	title_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	title.label_settings = title_settings
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Botões de ferramentas
	var compass_btn = Button.new()
	compass_btn.custom_minimum_size = Vector2(500, 100)
	compass_btn.text = LocalizationManager.translate("debug_compass", "ROLETA")
	compass_btn.add_theme_font_size_override("font_size", 45)
	var bg_ref_compass = weakref(modal_bg)
	var panel_ref_compass = weakref(debug_panel)
	compass_btn.pressed.connect(func():
		# Fechar menu primeiro
		var bg = bg_ref_compass.get_ref()
		var panel = panel_ref_compass.get_ref()
		if bg and is_instance_valid(bg):
			bg.queue_free()
		if panel and is_instance_valid(panel):
			panel.queue_free()
		# Abrir ferramenta depois
		call_deferred("_open_tool", "compass")
	)
	vbox.add_child(compass_btn)
	
	var dice_btn = Button.new()
	dice_btn.custom_minimum_size = Vector2(500, 100)
	dice_btn.text = LocalizationManager.translate("debug_dice", "DADOS")
	dice_btn.add_theme_font_size_override("font_size", 45)
	var bg_ref_dice = weakref(modal_bg)
	var panel_ref_dice = weakref(debug_panel)
	dice_btn.pressed.connect(func():
		# Fechar menu primeiro
		var bg = bg_ref_dice.get_ref()
		var panel = panel_ref_dice.get_ref()
		if bg and is_instance_valid(bg):
			bg.queue_free()
		if panel and is_instance_valid(panel):
			panel.queue_free()
		# Abrir ferramenta depois
		call_deferred("_open_tool", "dice")
	)
	vbox.add_child(dice_btn)
	
	var timer_btn = Button.new()
	timer_btn.custom_minimum_size = Vector2(500, 100)
	timer_btn.text = LocalizationManager.translate("debug_timer", "⏰ TIMER")
	timer_btn.add_theme_font_size_override("font_size", 45)
	var bg_ref_timer = weakref(modal_bg)
	var panel_ref_timer = weakref(debug_panel)
	timer_btn.pressed.connect(func():
		# Fechar menu primeiro
		var bg = bg_ref_timer.get_ref()
		var panel = panel_ref_timer.get_ref()
		if bg and is_instance_valid(bg):
			bg.queue_free()
		if panel and is_instance_valid(panel):
			panel.queue_free()
		# Abrir ferramenta depois
		call_deferred("_open_tool", "timer")
	)
	vbox.add_child(timer_btn)
	
	# Botão fechar
	var close_btn = Button.new()
	close_btn.custom_minimum_size = Vector2(500, 80)
	close_btn.text = LocalizationManager.translate("debug_close", "FECHAR")
	close_btn.add_theme_font_size_override("font_size", 40)
	var bg_ref_close = weakref(modal_bg)
	var panel_ref_close = weakref(debug_panel)
	close_btn.pressed.connect(func():
		var bg = bg_ref_close.get_ref()
		var panel = panel_ref_close.get_ref()
		if bg and is_instance_valid(bg):
			bg.queue_free()
		if panel and is_instance_valid(panel):
			panel.queue_free()
	)
	vbox.add_child(close_btn)
	
	# Adicionar hover effects
	UIManager.add_button_hover_effect(compass_btn)
	UIManager.add_button_hover_effect(dice_btn)
	UIManager.add_button_hover_effect(timer_btn)
	UIManager.add_button_hover_effect(close_btn)
	
	# Animar entrada
	debug_panel.modulate.a = 0.0
	debug_panel.scale = Vector2(0.8, 0.8)
	var tween = debug_panel.create_tween()
	if tween:
		tween.set_parallel(true)
		tween.tween_property(debug_panel, "modulate:a", 1.0, 0.3)
		tween.tween_property(debug_panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	safe_vibrate(50)

func _open_tool(tool_name: String):
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
	
	# Tentar usar métodos da cena atual primeiro
	if current_scene.get_script():
		var script_path = current_scene.get_script().resource_path
		if script_path.ends_with("generate_cards.gd"):
			match tool_name:
				"compass":
					if current_scene.has_method("_open_compass"):
						current_scene._open_compass()
						return
					elif current_scene.has("compass_spinner") and current_scene.compass_spinner:
						current_scene.compass_spinner.show_compass()
						return
				"dice":
					if current_scene.has_method("_open_dice"):
						current_scene._open_dice()
						return
					elif current_scene.has("dice_roller") and current_scene.dice_roller:
						current_scene.dice_roller.show_dice()
						return
				"timer":
					if current_scene.has_method("_open_timer"):
						current_scene._open_timer()
						return
					elif current_scene.has("timer_overlay") and current_scene.timer_overlay:
						current_scene.timer_overlay.start_timer(60, 0)
						return
	
	# Se não encontrou na cena atual, criar as ferramentas dinamicamente
	_create_tool_in_scene(tool_name, current_scene)

func _create_tool_in_scene(tool_name: String, scene: Node):
	match tool_name:
		"compass":
			var compass_scene = load("res://Scenes/compass_spinner.tscn")
			if compass_scene:
				var compass = compass_scene.instantiate()
				scene.add_child(compass)
				compass.z_index = 101
				compass.show_compass()
		"dice":
			var dice_scene = load("res://Scenes/dice_roller.tscn")
			if dice_scene:
				var dice = dice_scene.instantiate()
				scene.add_child(dice)
				dice.z_index = 101
				dice.show_dice()
		"timer":
			var timer_scene = load("res://Scenes/timer_overlay.tscn")
			if timer_scene:
				var timer = timer_scene.instantiate()
				scene.add_child(timer)
				timer.z_index = 100
				timer.start_timer(60, 0)

# Função segura para vibrar (Android e Web/iOS com Vibration API)
# IMPORTANTE: A permissão VIBRATE deve estar habilitada em:
# 1. export_presets.cfg: permissions/vibrate=true
# 2. android/build/AndroidManifest.xml: <uses-permission android:name="android.permission.VIBRATE" />
func safe_vibrate(duration_ms: int = 50) -> void:
	# Verificar se vibração está habilitada
	if not vibration_enabled:
		return
	
	# Validar duração
	if duration_ms <= 0:
		return
	
	var os_name = OS.get_name()
	
	# Android: usar Input.vibrate_handheld
	if os_name == "Android":
		if OS.is_debug_build():
			print("[UIManager] Vibrating: ", duration_ms, "ms")
		call_deferred("_do_vibrate_android", duration_ms)
	# Web/iOS: usar Vibration API do navegador (se disponível)
	elif os_name == "Web" or os_name == "iOS":
		call_deferred("_do_vibrate_web", duration_ms)

func _do_vibrate_android(duration_ms: int) -> void:
	if OS.get_name() != "Android":
		return
	
	if not is_inside_tree():
		if OS.is_debug_build():
			push_warning("[UIManager] Cannot vibrate: not in tree")
		return
	
	if duration_ms <= 0:
		return
	
	if OS.is_debug_build():
		print("[UIManager] Executing vibration: ", duration_ms, "ms")
	
	Input.vibrate_handheld(duration_ms)

func _do_vibrate_web(duration_ms: int) -> void:
	# No Web, usar JavaScript para acessar Vibration API
	# Isso funciona no iOS Safari e outros navegadores modernos
	if OS.get_name() != "Web":
		return
	
	if duration_ms <= 0:
		return
	
	# Usar JavaScript para vibrar (se suportado)
	# Nota: iOS Safari suporta Vibration API desde iOS 13
	# Em Godot 4, usar JavaScript singleton
	if OS.has_feature("web"):
		# Tentar usar JavaScript.eval se disponível
		var js_code = "if (navigator.vibrate) { navigator.vibrate(%d); }" % duration_ms
		# Nota: Em Godot 4, JavaScript pode não estar disponível diretamente
		# A vibração será silenciosamente ignorada se não suportada
		if OS.is_debug_build():
			print("[UIManager] Web vibration requested: ", duration_ms, "ms (may not work in all browsers)")

func _ensure_fade_overlay() -> void:
	if _fade_layer and is_instance_valid(_fade_layer):
		return

	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 512

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.z_index = 10
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	_fade_layer.add_child(_fade_rect)
	_fade_layer.visible = false

	var root := get_tree().root
	if root:
		root.add_child(_fade_layer)

func change_scene_with_fade(scene_path: String, duration: float = 0.3):
	_ensure_fade_overlay()

	var tree := get_tree()
	if not tree:
		return
		
	var root := tree.root
	if not root:
		return
		
	if not is_instance_valid(_fade_layer) or not is_instance_valid(_fade_rect):
		_ensure_fade_overlay()
	
	if _fade_layer.get_parent() != root:
		root.add_child(_fade_layer)

	_fade_layer.visible = true
	_fade_rect.color = Color(0, 0, 0, 0)

	if not _fade_rect.is_inside_tree():
		return
		
	var fade_in := _fade_rect.create_tween()
	if not fade_in:
		_fade_layer.visible = false
		return
		
	fade_in.tween_property(_fade_rect, "color:a", 1.0, duration)
	await fade_in.finished

	if not is_instance_valid(_fade_rect):
		return

	var err := tree.change_scene_to_file(scene_path)
	if err != OK:
		push_error("[UIManager] Falha ao trocar cena para %s (erro %d)" % [scene_path, err])
		if is_instance_valid(_fade_layer):
			_fade_layer.visible = false
		return
	
	await tree.create_timer(0.01).timeout

	if not is_instance_valid(_fade_rect) or not _fade_rect.is_inside_tree():
		if is_instance_valid(_fade_layer):
			_fade_layer.visible = false
		return

	_fade_rect.color = Color(0, 0, 0, 1)
	var fade_out := _fade_rect.create_tween()
	if not fade_out:
		if is_instance_valid(_fade_layer):
			_fade_layer.visible = false
		return
		
	fade_out.tween_property(_fade_rect, "color:a", 0.0, duration)
	await fade_out.finished

	if is_instance_valid(_fade_layer):
		_fade_layer.visible = false

func add_button_hover_effect(button: Button):
	if not button or not is_instance_valid(button):
		return

	button.mouse_entered.connect(func():
		if not is_instance_valid(button):
			return
		_tween_button_scale(button, Vector2(1.05, 1.05), 0.2)
		safe_vibrate(20)
	)
	
	button.mouse_exited.connect(func():
		if not is_instance_valid(button):
			return
		_tween_button_scale(button, Vector2.ONE, 0.2)
	)
	
	button.button_down.connect(func():
		if not is_instance_valid(button):
			return
		_tween_button_scale(button, Vector2(0.95, 0.95), 0.1)
		safe_vibrate(50)
	)
	
	button.button_up.connect(func():
		if not is_instance_valid(button):
			return
		_tween_button_scale(button, Vector2(1.05, 1.05), 0.1)
	)

func _tween_button_scale(button: Button, target: Vector2, duration: float) -> void:
	if not button or not is_instance_valid(button):
		if OS.is_debug_build():
			push_warning("[UIManager] Button invalid in _tween_button_scale")
		return
	
	# Verificar se o botão ainda está na árvore antes de criar tween
	if not button.is_inside_tree():
		if OS.is_debug_build():
			push_warning("[UIManager] Button not in tree in _tween_button_scale")
		return
	
	# Matar tween anterior se existir
	if button.has_meta("_hover_tween"):
		var existing = button.get_meta("_hover_tween")
		if existing and existing is Tween and is_instance_valid(existing):
			existing.kill()
		button.remove_meta("_hover_tween")
	
	# Criar novo tween com verificação adicional
	if not is_instance_valid(button) or not button.is_inside_tree():
		if OS.is_debug_build():
			push_warning("[UIManager] Button became invalid before creating tween")
		return
	
	var tween = button.create_tween()
	if not tween:
		if OS.is_debug_build():
			push_error("[UIManager] Failed to create tween for button")
		return
		
	button.set_meta("_hover_tween", tween)
	tween.tween_property(button, "scale", target, duration)
	
	# Limpar meta quando terminar
	var button_ref = weakref(button)
	var tween_ref = weakref(tween)
	tween.finished.connect(func():
		var btn = button_ref.get_ref()
		var tw = tween_ref.get_ref()
		if btn and is_instance_valid(btn) and btn.is_inside_tree() and btn.has_meta("_hover_tween"):
			var stored_tween = btn.get_meta("_hover_tween")
			if stored_tween == tw:
				btn.remove_meta("_hover_tween")
	)

func animate_panel_entrance(panel: Control, delay: float = 0.0):
	if not panel or not is_instance_valid(panel):
		if OS.is_debug_build():
			push_warning("[UIManager] Panel invalid in animate_panel_entrance")
		return

	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)
	
	await get_tree().create_timer(delay).timeout
	
	if not is_instance_valid(panel) or not panel.is_inside_tree():
		if OS.is_debug_build():
			push_warning("[UIManager] Panel became invalid after delay in animate_panel_entrance")
		return
	
	var tween = panel.create_tween()
	if not tween:
		if OS.is_debug_build():
			push_error("[UIManager] Failed to create tween for panel entrance")
		return
		
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.4)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func create_glassmorphism_panel(size: Vector2, position: Vector2, color: Color = Color(0.1, 0.1, 0.1, 0.8)) -> Panel:
	var panel = Panel.new()
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(20)
	style.shadow_size = 20
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1, 0.1)
	
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = size
	panel.position = position
	
	return panel

func pulse_element(element: Control, scale_to: float = 1.2, duration: float = 0.3):
	if not element or not is_instance_valid(element) or not element.is_inside_tree():
		return
	var tween = element.create_tween()
	if not tween:
		return
	tween.tween_property(element, "scale", Vector2(scale_to, scale_to), duration / 2)
	tween.tween_property(element, "scale", Vector2.ONE, duration / 2)

func show_loading_overlay(parent: Control, message: String = "Carregando...") -> Control:
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.size = parent.get_viewport().size
	overlay.z_index = 1000
	
	var label = Label.new()
	label.text = message
	var settings = LabelSettings.new()
	settings.font_size = 50
	label.label_settings = settings
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = overlay.size
	
	overlay.add_child(label)
	parent.add_child(overlay)
	
	# Animar dots
	_animate_loading_dots(label)
	
	return overlay

func _animate_loading_dots(label: Label):
	var base_text = label.text.replace("...", "")
	var dots = 0
	
	while is_instance_valid(label):
		dots = (dots + 1) % 4
		label.text = base_text + ".".repeat(dots)
		await get_tree().create_timer(0.5).timeout
