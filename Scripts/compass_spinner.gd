extends Control

signal direction_selected(direction: String)

@onready var arrow = $Background/CompassCircle/Arrow
@onready var spin_button = $Background/VBoxContainer/SpinButton
@onready var result_label = $Background/VBoxContainer/ResultLabel
@onready var background = $Background

var is_spinning: bool = false
var tween: Tween

func _ready():
	visible = false
	result_label.text = ""
	_update_ui_texts()
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)

func _update_ui_texts():
	# Atualizar textos traduzidos
	if has_node("Background/Title"):
		$Background/Title.text = LocalizationManager.translate("compass_title", "ROLETA")
	if spin_button:
		spin_button.text = LocalizationManager.translate("compass_spin_button", "GIRAR ROLETA")
	if has_node("Background/VBoxContainer/CloseButton"):
		$Background/VBoxContainer/CloseButton.text = LocalizationManager.translate("compass_close_button", "Fechar")

func show_compass():
	visible = true
	spin_button.disabled = false
	result_label.text = ""
	arrow.rotation_degrees = 0
	
	# Animar entrada com elastic
	modulate.a = 0.0
	scale = Vector2(0.6, 0.6)
	rotation_degrees = 15
	if tween and is_instance_valid(tween):
		tween.kill()
	if not is_inside_tree():
		return
	tween = self.create_tween()
	if not tween:
		return
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	tween.tween_property(self, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", 0, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Vibrar
	UIManager.safe_vibrate(100)

func hide_compass():
	if tween and is_instance_valid(tween):
		tween.kill()
	if not is_inside_tree():
		visible = false
		return
	tween = self.create_tween()
	if not tween:
		visible = false
		return
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.3)
	await tween.finished
	visible = false

func _on_spin_button_pressed():
	if is_spinning:
		return
	
	is_spinning = true
	spin_button.disabled = true
	result_label.text = LocalizationManager.translate("compass_spinning", "Girando...")
	
	# Escolher ângulo aleatório (0-360 graus, como segundos de um relógio)
	var target_angle = randi() % 360
	
	# Adicionar rotações completas para efeito visual mais longo
	var extra_rotations = randi() % 5 + 8  # 8 a 12 rotações completas
	var total_rotation = (extra_rotations * 360) + target_angle
	
	# Normalizar para 0-360
	total_rotation = fmod(total_rotation, 360.0)
	
	# Animar rotação (gira no centro do círculo)
	if not arrow or not is_instance_valid(arrow) or not arrow.is_inside_tree():
		return
	if tween and is_instance_valid(tween):
		tween.kill()
	tween = arrow.create_tween()
	if not tween:
		return
	tween.tween_property(arrow, "rotation_degrees", total_rotation, 3.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	# Vibrar
	UIManager.safe_vibrate(300)
	
	# Partículas na seta
	if get_parent():
		ParticlesManager.create_star_particles(get_parent(), arrow.global_position, Color(1, 0.2, 0.2, 1))
	
	# Converter ângulo para direção aproximada (apenas para exibição)
	var direction_name = _angle_to_direction_name(target_angle)
	
	# Mostrar resultado
	result_label.text = "☞ " + str(target_angle) + "° ☜"
	result_label.add_theme_font_size_override("font_size", 50)
	
	# Pulsar resultado
	if not result_label or not is_instance_valid(result_label) or not result_label.is_inside_tree():
		return
	if tween and is_instance_valid(tween):
		tween.kill()
	tween = result_label.create_tween()
	if not tween:
		return
	tween.tween_property(result_label, "scale", Vector2(1.3, 1.3), 0.2)
	tween.tween_property(result_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.6).timeout
	
	is_spinning = false
	spin_button.disabled = false
	
	direction_selected.emit(direction_name)

func _angle_to_direction_name(angle: float) -> String:
	# Converter ângulo para nome de direção aproximado (apenas para referência)
	var normalized = fmod(angle + 22.5, 360.0)  # Offset para centralizar
	if normalized < 45:
		return LocalizationManager.translate("compass_direction_north", "Norte")
	elif normalized < 90:
		return LocalizationManager.translate("compass_direction_northeast", "Nordeste")
	elif normalized < 135:
		return LocalizationManager.translate("compass_direction_east", "Leste")
	elif normalized < 180:
		return LocalizationManager.translate("compass_direction_southeast", "Sudeste")
	elif normalized < 225:
		return LocalizationManager.translate("compass_direction_south", "Sul")
	elif normalized < 270:
		return LocalizationManager.translate("compass_direction_southwest", "Sudoeste")
	elif normalized < 315:
		return LocalizationManager.translate("compass_direction_west", "Oeste")
	else:
		return LocalizationManager.translate("compass_direction_northwest", "Noroeste")

func _on_close_button_pressed():
	hide_compass()
