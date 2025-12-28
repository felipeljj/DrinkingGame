extends Control

@onready var title = $Title
@onready var logo = $Sprite2D
@onready var play_button = $HBoxContainer/VBoxContainer/Play
@onready var instructions_button = $HBoxContainer/VBoxContainer/howTo
@onready var settings_button = $HBoxContainer/VBoxContainer/Settings
@onready var credits_button = $HBoxContainer/VBoxContainer/Credits
@onready var achievements_button = $HBoxContainer/VBoxContainer/Achievements

# Parallax
var touch_position = Vector2.ZERO
var logo_original_position = Vector2.ZERO
var title_original_position = Vector2.ZERO
var logo_original_scale = Vector2.ONE
var logo_original_rotation = 0.0

func _ready() -> void:
	# Salvar posições originais ANTES de modificar
	logo_original_position = logo.position
	title_original_position = title.position
	logo_original_scale = logo.scale
	logo_original_rotation = logo.rotation
	
	# Adicionar partículas flutuantes
	ParticlesManager.create_bubble_particles(self)
	
	# Atualizar textos traduzidos
	_update_ui_texts()
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)
	
	# Animações de entrada
	_animate_entrance()
	
	# Adicionar hover effects nos botões
	UIManager.add_button_hover_effect(play_button)
	UIManager.add_button_hover_effect(instructions_button)
	UIManager.add_button_hover_effect(settings_button)
	UIManager.add_button_hover_effect(credits_button)
	UIManager.add_button_hover_effect(achievements_button)

func _update_ui_texts():
	if play_button:
		play_button.text = LocalizationManager.translate("menu_play", "JOGAR")
	if instructions_button:
		instructions_button.text = LocalizationManager.translate("menu_instructions", "Instruções")
	if settings_button:
		settings_button.text = LocalizationManager.translate("menu_settings", "Configurações")
	if credits_button:
		credits_button.text = LocalizationManager.translate("menu_credits", "Créditos")
	if achievements_button:
		achievements_button.text = LocalizationManager.translate("menu_achievements", "Conquistas")

func _animate_entrance():
	# Começar invisível/fora de posição
	title.modulate.a = 0.0
	title.position.y = title_original_position.y - 200
	
	logo.modulate.a = 0.0
	logo.scale = Vector2(0.3, 0.3)
	logo.rotation_degrees = -45
	
	play_button.modulate.a = 0.0
	play_button.scale = Vector2(0.5, 0.5)
	
	instructions_button.modulate.a = 0.0
	instructions_button.scale = Vector2(0.5, 0.5)
	
	# Animar título de volta para posição original
	var title_tween = title.create_tween().set_parallel(true)
	title_tween.tween_property(title, "modulate:a", 1.0, 0.6)
	title_tween.tween_property(title, "position:y", title_original_position.y, 0.6).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	# Animar logo (com delay)
	await get_tree().create_timer(0.2).timeout
	var logo_tween = logo.create_tween().set_parallel(true)
	logo_tween.tween_property(logo, "modulate:a", 1.0, 0.5)
	logo_tween.tween_property(logo, "scale", logo_original_scale, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	logo_tween.tween_property(logo, "rotation", logo_original_rotation, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Animar botões
	await get_tree().create_timer(0.1).timeout
	var play_tween = play_button.create_tween().set_parallel(true)
	play_tween.tween_property(play_button, "modulate:a", 1.0, 0.4)
	play_tween.tween_property(play_button, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.1).timeout
	var inst_tween = instructions_button.create_tween().set_parallel(true)
	inst_tween.tween_property(instructions_button, "modulate:a", 1.0, 0.4)
	inst_tween.tween_property(instructions_button, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _input(event):
	# Efeito parallax no logo
	if event is InputEventScreenTouch or event is InputEventMouseMotion:
		touch_position = event.position

func _process(delta: float) -> void:
	# Parallax suave
	if not logo or not is_instance_valid(logo):
		return
	
	var screen_center = get_viewport_rect().size / 2
	var offset = (touch_position - screen_center) * 0.02
	var target_pos = logo_original_position + offset
	logo.position = logo.position.lerp(target_pos, delta * 3)

func _on_play_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/game_hub.tscn")

func _on_instructions_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/instructions.tscn")

func _on_settings_pressed() -> void:
	var settings_scene = load("res://Scenes/settings.tscn")
	if settings_scene:
		var settings = settings_scene.instantiate()
		add_child(settings)

func _on_credits_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/credits.tscn")

func _on_achievements_pressed() -> void:
	UIManager.change_scene_with_fade("res://Scenes/achievements.tscn")
