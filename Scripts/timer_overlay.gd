extends Control

signal timer_finished

@onready var countdown_label = $CountdownLabel
@onready var background = $Background

var time_remaining: int = 10
var is_active: bool = false
var tween: Tween

func _ready():
	visible = false

func start_timer(seconds: int, cooldown: float = 10.0):
	time_remaining = seconds
	
	# Cooldown antes de iniciar
	await get_tree().create_timer(cooldown).timeout
	
	# Mostrar overlay
	visible = true
	is_active = true
	
	# Animar entrada com glassmorphism
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	if tween and is_instance_valid(tween):
		tween.kill()
	if not is_inside_tree():
		return
	tween = self.create_tween()
	if not tween:
		return
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	tween.tween_property(self, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Vibrar
	UIManager.safe_vibrate(100)
	
	# Iniciar contagem
	_update_display()
	_start_countdown()

func _start_countdown():
	while time_remaining > 0 and is_active:
		await get_tree().create_timer(1.0).timeout
		time_remaining -= 1
		_update_display()
		
		# Pulsar quando estiver acabando
		if time_remaining <= 3:
			_pulse_warning()
		
		# Vibrar no último segundo
		if time_remaining == 1:
			UIManager.safe_vibrate(100)
	
	if is_active:
		_finish_timer()

func _update_display():
	if countdown_label:
		countdown_label.text = str(time_remaining)
		
		# Mudar cor conforme o tempo
		if time_remaining <= 3:
			countdown_label.label_settings.font_color = Color("e5193f")
		elif time_remaining <= 5:
			countdown_label.label_settings.font_color = Color("ffb347")
		else:
			countdown_label.label_settings.font_color = Color("ffffff")

func _pulse_warning():
	if not countdown_label or not is_instance_valid(countdown_label) or not countdown_label.is_inside_tree():
		return
	if tween and is_instance_valid(tween):
		tween.kill()
	tween = countdown_label.create_tween()
	if not tween:
		return
	tween.tween_property(countdown_label, "scale", Vector2(1.3, 1.3), 0.2)
	tween.tween_property(countdown_label, "scale", Vector2.ONE, 0.2)

func _finish_timer():
	is_active = false
	
	# Vibrar forte
	UIManager.safe_vibrate(500)
	
	# Partículas de explosão
	if get_parent():
		ParticlesManager.create_confetti(get_parent(), countdown_label.global_position, Color(1, 0.2, 0.2, 1), 40)
	
	# Animar saída
	if tween and is_instance_valid(tween):
		tween.kill()
	if not is_inside_tree():
		visible = false
		timer_finished.emit()
		return
	tween = self.create_tween()
	if not tween:
		visible = false
		timer_finished.emit()
		return
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.5)
	await tween.finished
	
	visible = false
	timer_finished.emit()

func cancel_timer():
	is_active = false
	visible = false
	if tween and is_instance_valid(tween):
		tween.kill()

