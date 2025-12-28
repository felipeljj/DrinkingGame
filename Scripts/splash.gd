extends Control

@onready var logo_label = $LogoLabel

func _ready() -> void:
	print("[Splash] _ready chamado")
	
	# Aguardar um frame para garantir que tudo está na árvore
	await get_tree().process_frame
	
	# Verificar se o logo_label existe
	if not logo_label or not is_instance_valid(logo_label):
		print("[Splash] ERRO: LogoLabel não encontrado! Mudando para menu...")
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
		return
	
	# Verificar se está na árvore
	if not logo_label.is_inside_tree():
		print("[Splash] ERRO: LogoLabel não está na árvore! Mudando para menu...")
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
		return
	
	print("[Splash] LogoLabel encontrado, iniciando animação...")
	
	# Começar invisível
	logo_label.modulate.a = 0.0
	logo_label.scale = Vector2(0.5, 0.5)
	
	# Animação de entrada
	var tween = logo_label.create_tween()
	if not tween:
		print("[Splash] ERRO: Não foi possível criar tween! Mudando para menu...")
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
		return
	
	tween.set_parallel(true)
	tween.tween_property(logo_label, "modulate:a", 1.0, 0.8)
	tween.tween_property(logo_label, "scale", Vector2.ONE, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Vibrar levemente
	UIManager.safe_vibrate(100)
	
	# Aguardar a animação de entrada terminar
	await tween.finished
	
	print("[Splash] Animação de entrada concluída, aguardando 4 segundos...")
	
	# Aguardar 4 segundos na tela
	await get_tree().create_timer(2.0).timeout
	
	print("[Splash] 4 segundos passados, iniciando fade out...")
	
	# Verificar novamente antes do fade out
	if not is_instance_valid(logo_label) or not logo_label.is_inside_tree():
		print("[Splash] LogoLabel inválido durante fade out, mudando para menu...")
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
		return
	
	# Fade out
	tween = logo_label.create_tween()
	if tween:
		tween.tween_property(logo_label, "modulate:a", 0.0, 0.5)
		await tween.finished
	
	print("[Splash] Fade out concluído, mudando para menu...")
	
	# Mudar para menu
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
