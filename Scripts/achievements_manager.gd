extends Node

# Singleton para gerenciar conquistas

signal achievement_unlocked(achievement_id: String)

var achievements: Dictionary = {}

# Estrutura de conquistas (IDs e ícones - nomes/descrições são traduzidos dinamicamente)
var achievement_definitions = {
	"all_cards_completed": {
		"name_key": "achievement_all_cards_completed_name",
		"desc_key": "achievement_all_cards_completed_desc",
		"icon": "🏆"
	},
	"pack_classico_completed": {
		"name_key": "achievement_pack_classico_completed_name",
		"desc_key": "achievement_pack_classico_completed_desc",
		"icon": "🎴"
	},
	"pack_nonsense_completed": {
		"name_key": "achievement_pack_nonsense_completed_name",
		"desc_key": "achievement_pack_nonsense_completed_desc",
		"icon": "🤪"
	},
	"pack_weirdo_completed": {
		"name_key": "achievement_pack_weirdo_completed_name",
		"desc_key": "achievement_pack_weirdo_completed_desc",
		"icon": "👽"
	},
	"pack_languages_completed": {
		"name_key": "achievement_pack_languages_completed_name",
		"desc_key": "achievement_pack_languages_completed_desc",
		"icon": "🌍"
	},
	"pack_pool_completed": {
		"name_key": "achievement_pack_pool_completed_name",
		"desc_key": "achievement_pack_pool_completed_desc",
		"icon": "🗳️"
	},
	"pack_spicy_completed": {
		"name_key": "achievement_pack_spicy_completed_name",
		"desc_key": "achievement_pack_spicy_completed_desc",
		"icon": "🌶️"
	},
	"first_rare": {
		"name_key": "achievement_first_rare_name",
		"desc_key": "achievement_first_rare_desc",
		"icon": "⭐"
	},
	"collector": {
		"name_key": "achievement_collector_name",
		"desc_key": "achievement_collector_desc",
		"icon": "💎"
	},
	"marathon": {
		"name_key": "achievement_marathon_name",
		"desc_key": "achievement_marathon_desc",
		"icon": "🏃"
	},
	"social": {
		"name_key": "achievement_social_name",
		"desc_key": "achievement_social_desc",
		"icon": "🦋"
	},
	"perfectionist": {
		"name_key": "achievement_perfectionist_name",
		"desc_key": "achievement_perfectionist_desc",
		"icon": "✨"
	}
}

func _ready() -> void:
	_load_achievements()

func _load_achievements() -> void:
	var file_path = "user://achievements.json"
	if not FileAccess.file_exists(file_path):
		# Inicializar todas as conquistas como não desbloqueadas
		for achievement_id in achievement_definitions.keys():
			achievements[achievement_id] = {
				"unlocked": false,
				"unlocked_date": null
			}
		_save_achievements()
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			achievements = json.data
			# Garantir que todas as conquistas existam
			for achievement_id in achievement_definitions.keys():
				if not achievements.has(achievement_id):
					achievements[achievement_id] = {
						"unlocked": false,
						"unlocked_date": null
					}
			_save_achievements()
		else:
			push_error("Erro ao parsear arquivo de conquistas: " + file_path)
			# Inicializar padrão
			for achievement_id in achievement_definitions.keys():
				achievements[achievement_id] = {
					"unlocked": false,
					"unlocked_date": null
				}

func _save_achievements() -> void:
	var file_path = "user://achievements.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(achievements, "\t")
		file.store_string(json_string)
		file.close()
	else:
		push_error("Erro ao salvar arquivo de conquistas: " + file_path)

func unlock_achievement(achievement_id: String) -> bool:
	if not achievement_definitions.has(achievement_id):
		push_error("Conquista não encontrada: " + achievement_id)
		return false
	
	if achievements.has(achievement_id) and achievements[achievement_id].get("unlocked", false):
		return false  # Já desbloqueada
	
	# Desbloquear
	if not achievements.has(achievement_id):
		achievements[achievement_id] = {}
	
	achievements[achievement_id]["unlocked"] = true
	achievements[achievement_id]["unlocked_date"] = Time.get_datetime_string_from_system()
	
	_save_achievements()
	achievement_unlocked.emit(achievement_id)
	
	return true

func is_achievement_unlocked(achievement_id: String) -> bool:
	if not achievements.has(achievement_id):
		return false
	return achievements[achievement_id].get("unlocked", false)

func get_achievement_info(achievement_id: String) -> Dictionary:
	if not achievement_definitions.has(achievement_id):
		return {}
	
	var def = achievement_definitions[achievement_id]
	var info = {}
	
	# Traduzir nome e descrição usando LocalizationManager
	info["name"] = LocalizationManager.translate(def.get("name_key", ""), def.get("name_key", "Achievement"))
	info["description"] = LocalizationManager.translate(def.get("desc_key", ""), def.get("desc_key", ""))
	info["icon"] = def.get("icon", "🏆")
	
	if achievements.has(achievement_id):
		info["unlocked"] = achievements[achievement_id].get("unlocked", false)
		info["unlocked_date"] = achievements[achievement_id].get("unlocked_date", null)
	else:
		info["unlocked"] = false
		info["unlocked_date"] = null
	
	return info

func get_all_achievements() -> Array:
	var all_achievements = []
	for achievement_id in achievement_definitions.keys():
		all_achievements.append(get_achievement_info(achievement_id))
	return all_achievements

