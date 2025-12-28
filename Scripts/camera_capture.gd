extends Control

signal photo_captured(path: String)
signal capture_cancelled()

@onready var preview: TextureRect = $Panel/VBox/Preview
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var capture_button: Button = $Panel/VBox/Buttons/CaptureButton
@onready var cancel_button: Button = $Panel/VBox/Buttons/CancelButton

var feed: CameraFeed = null
var feed_texture: Texture2D = null
var permission_requested := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	UIManager.animate_panel_entrance($Panel)
	_init_camera()
	
	capture_button.pressed.connect(_on_capture_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

func _init_camera() -> void:
	status_label.text = "Abrindo câmera..."
	
	if OS.has_feature("android"):
		# Solicitar permissão e aguardar
		await _request_android_camera_permission()
		# Aguardar um pouco para a permissão ser processada
		await get_tree().create_timer(0.5).timeout
	
	# Verificar se CameraServer está disponível
	if not Engine.has_singleton("CameraServer"):
		print("[Camera] CameraServer não disponível")
		_enable_screenshot_mode("Câmera não disponível no dispositivo")
		return
	
	# Aguardar feeds serem inicializados (pode levar um tempo no Android)
	var max_attempts = 10
	var attempt = 0
	while CameraServer.get_feed_count() == 0 and attempt < max_attempts:
		await get_tree().create_timer(0.2).timeout
		attempt += 1
		print("[Camera] Tentativa %d/%d - Feeds: %d" % [attempt, max_attempts, CameraServer.get_feed_count()])
	
	if CameraServer.get_feed_count() == 0:
		print("[Camera] Nenhum feed de câmera disponível após %d tentativas" % max_attempts)
		_enable_screenshot_mode("Nenhuma câmera detectada")
		return
	
	print("[Camera] %d feed(s) de câmera encontrado(s)" % CameraServer.get_feed_count())
	
	# Procurar câmera traseira primeiro
	for i in range(CameraServer.get_feed_count()):
		var candidate: CameraFeed = CameraServer.get_feed(i)
		if candidate:
			print("[Camera] Feed %d: posição=%d, nome=%s" % [i, candidate.get_camera_position(), candidate.get_name()])
			if candidate.get_camera_position() == CameraFeed.CAMERA_POSITION_BACK:
				feed = candidate
				break
	
	# Se não encontrou traseira, usar a primeira disponível
	if not feed:
		feed = CameraServer.get_feed(0)
	
	if not feed:
		print("[Camera] Falha ao obter feed de câmera")
		_enable_screenshot_mode("Falha ao acessar câmera")
		return
	
	print("[Camera] Usando feed: %s" % feed.get_name())
	
	# Ativar feed
	feed.set_active(true)
	
	# Aguardar um frame para o feed inicializar
	await get_tree().process_frame
	
	feed_texture = feed.get_texture()
	
	if not feed_texture:
		print("[Camera] Feed ativado mas sem textura disponível")
		# Tentar novamente após mais um frame
		await get_tree().create_timer(0.3).timeout
		feed_texture = feed.get_texture()
		
		if not feed_texture:
			_enable_screenshot_mode("Câmera indisponível")
			return
	
	preview.texture = feed_texture
	status_label.text = "Toque para capturar"
	print("[Camera] Câmera pronta para uso")

func _request_android_camera_permission() -> void:  # Note: async function
	if not OS.has_feature("android"):
		return
	
	if not OS.has_method("request_permission"):
		print("[Camera] OS.request_permission não disponível")
		return
	
	# Verificar se já tem permissão
	if OS.has_method("has_permission"):
		if OS.has_permission("android.permission.CAMERA"):
			print("[Camera] Permissão de câmera já concedida")
			return
	
	if permission_requested:
		print("[Camera] Permissão já foi solicitada anteriormente")
		return
	
	print("[Camera] Solicitando permissão de câmera...")
	permission_requested = true
	OS.request_permission("android.permission.CAMERA")
	
	# Aguardar um pouco para o sistema processar
	await get_tree().create_timer(0.3).timeout
	
	# Verificar se foi concedida
	if OS.has_method("has_permission"):
		if OS.has_permission("android.permission.CAMERA"):
			print("[Camera] Permissão concedida!")
		else:
			print("[Camera] Permissão negada ou ainda pendente")

func _on_capture_pressed() -> void:
	if feed_texture:
		var image := feed_texture.get_image()
		if image:
			var path := _save_image(image)
			if path != "":
				emit_signal("photo_captured", path)
				_close()
				return
		_show_error("Erro ao salvar foto")
		return
	
	# Fallback para screenshot
	var screenshot_path := await _capture_screenshot()
	if screenshot_path != "":
		emit_signal("photo_captured", screenshot_path)
		_close()
	else:
		_show_error("Erro ao salvar captura de tela")

func _on_cancel_pressed() -> void:
	emit_signal("capture_cancelled")
	_close()

func _show_error(message: String) -> void:
	status_label.text = message
	capture_button.disabled = true

func _close() -> void:
	if feed:
		feed.set_active(false)
	feed = null
	queue_free()

func _enable_screenshot_mode(message: String = "Nenhuma câmera detectada. Capturando a tela.") -> void:
	feed = null
	feed_texture = null
	preview.texture = null
	status_label.text = message
	capture_button.disabled = false

func _save_image(image: Image) -> String:
	var timestamp := Time.get_unix_time_from_system()
	var filename := "DrinksDeck_%d.png" % timestamp
	
	# No Android, salvar na galeria (Pictures)
	if OS.has_feature("android"):
		# Solicitar permissão se necessário (Android 13+ usa READ_MEDIA_IMAGES)
		if OS.has_method("request_permission") and OS.has_method("has_permission"):
			if not OS.has_permission("android.permission.READ_MEDIA_IMAGES") and not OS.has_permission("android.permission.WRITE_EXTERNAL_STORAGE"):
				OS.request_permission("android.permission.READ_MEDIA_IMAGES")
				await get_tree().create_timer(0.3).timeout
		
		# Tentar salvar em /storage/emulated/0/Pictures/DrinksDeck/
		var android_path := "/storage/emulated/0/Pictures/DrinksDeck/"
		var dir := DirAccess.open("/storage/emulated/0/Pictures/")
		
		if dir:
			if not dir.dir_exists("DrinksDeck"):
				dir.make_dir("DrinksDeck")
			
			var full_path := android_path + filename
			var err := image.save_png(full_path)
			
			if err == OK:
				print("✅ Foto salva na galeria: ", full_path)
				return full_path
			else:
				print("❌ Erro ao salvar em galeria, tentando user://")
		
		# Fallback: salvar em user://
		var user_dir := DirAccess.open("user://")
		if user_dir and not user_dir.dir_exists("photos"):
			user_dir.make_dir("photos")
		var user_path := "user://photos/" + filename
		var err := image.save_png(user_path)
		if err == OK:
			print("✅ Foto salva em user://: ", user_path)
			return user_path
	
	# Desktop/outros: salvar em user://
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("photos"):
		dir.make_dir("photos")
	var path := "user://photos/" + filename
	var err := image.save_png(path)
	return path if err == OK else ""

func _capture_screenshot() -> String:
	await get_tree().process_frame
	var viewport_texture := get_viewport().get_texture()
	if not viewport_texture:
		return ""
	var image := viewport_texture.get_image()
	if not image:
		return ""
	return _save_image(image)

