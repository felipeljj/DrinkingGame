extends Node

# Singleton para gerenciar traduções e localização

var current_language: String = "pt"
var translations: Dictionary = {}

signal language_changed(new_language: String)

func _ready() -> void:
	# Carregar idioma salvo
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		current_language = config.get_value("settings", "language", "pt")
	else:
		current_language = "pt"
	
	# Carregar traduções do idioma atual
	load_translations(current_language)

func load_translations(lang: String) -> void:
	translations.clear()
	
	var file_path = "res://translations/" + lang + ".json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			translations = json.data
		else:
			push_error("Erro ao parsear arquivo de tradução: " + file_path)
			# Fallback para português se houver erro
			if lang != "pt":
				load_translations("pt")
	else:
		push_error("Arquivo de tradução não encontrado: " + file_path)
		# Fallback para português se arquivo não existir
		if lang != "pt":
			load_translations("pt")

func translate(key: String, default: String = "") -> String:
	# Se ainda não carregou traduções, tentar carregar
	if translations.is_empty() and current_language != "":
		load_translations(current_language)
	
	if translations.has(key):
		return translations[key]
	
	# Se não encontrou e tem default, retorna default
	if default != "":
		return default
	
	# Se não encontrou e não tem default, retorna a chave
	return key

# Função removida - emojis restaurados

func set_language(lang: String) -> void:
	if lang == current_language:
		return
	
	current_language = lang
	load_translations(lang)
	
	# Salvar preferência
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		config = ConfigFile.new()
	
	config.set_value("settings", "language", lang)
	config.save("user://settings.cfg")
	
	language_changed.emit(lang)

func get_language() -> String:
	return current_language

func get_cards(category: String) -> Array:
	# Retornar cartas traduzidas de uma categoria
	var cards_key = "cards_" + category
	if translations.has(cards_key):
		return translations[cards_key]
	return []
