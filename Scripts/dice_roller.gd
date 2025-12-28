extends Control

signal dice_rolled(result: int)

@onready var dice_label = $Background/VBoxContainer/DiceLabel
@onready var roll_button = $Background/VBoxContainer/RollButton
@onready var background = $Background

var is_rolling: bool = false
var tween: Tween

func _ready():
	visible = false
	_update_ui_texts()
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)

func _update_ui_texts():
	# Atualizar textos traduzidos
	if has_node("Background/VBoxContainer/Title"):
		$Background/VBoxContainer/Title.text = LocalizationManager.translate("dice_title", "DADO")
	if roll_button:
		roll_button.text = LocalizationManager.translate("dice_roll_button", "ROLAR DADO")
	if has_node("Background/VBoxContainer/CloseButton"):
		$Background/VBoxContainer/CloseButton.text = LocalizationManager.translate("dice_close_button", "Fechar")

func show_dice():
	visible = true
	roll_button.disabled = false
	dice_label.text = "?"
	
	# Animar entrada com elastic
	modulate.a = 0.0
	scale = Vector2(0.7, 0.7)
	rotation_degrees = -15
	if tween and is_instance_valid(tween):
		tween.kill()
	if not is_inside_tree():
		return
	tween = self.create_tween()
	if not tween:
		return
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", 0, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Vibrar
	UIManager.safe_vibrate(100)

func hide_dice():
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

func _on_roll_button_pressed():
	if is_rolling:
		return
	
	is_rolling = true
	roll_button.disabled = true
	
	# Animação de rolagem
	var roll_duration = 1.5
	var roll_steps = 15
	var step_duration = roll_duration / roll_steps
	
	for i in range(roll_steps):
		dice_label.text = str(randi() % 6 + 1)
		
		# Pulsar
		if not dice_label or not is_instance_valid(dice_label) or not dice_label.is_inside_tree():
			break
		if tween and is_instance_valid(tween):
			tween.kill()
		tween = dice_label.create_tween()
		if tween:
			tween.tween_property(dice_label, "scale", Vector2(1.2, 1.2), step_duration / 2)
			tween.tween_property(dice_label, "scale", Vector2.ONE, step_duration / 2)
		
		await get_tree().create_timer(step_duration).timeout
	
	# Resultado final
	var result = randi() % 6 + 1
	dice_label.text = str(result)
	
	# Vibrar
	UIManager.safe_vibrate(200)
	
	# Partículas de estrelas
	if get_parent():
		ParticlesManager.create_star_particles(get_parent(), dice_label.global_position, Color(1, 0.843, 0, 1))
	
	# Animação de resultado
	if not dice_label or not is_instance_valid(dice_label) or not dice_label.is_inside_tree():
		return
	if tween and is_instance_valid(tween):
		tween.kill()
	tween = dice_label.create_tween()
	if tween:
		tween.tween_property(dice_label, "scale", Vector2(1.5, 1.5), 0.2)
		tween.tween_property(dice_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.5).timeout
	
	is_rolling = false
	roll_button.disabled = false
	
	dice_rolled.emit(result)

func _on_close_button_pressed():
	hide_dice()
