extends Node

# Sistema de gerenciamento de novidades/updates do app

signal news_updated

const SAVE_PATH = "user://news_data.json"

# Lista de novidades - adicione novas no topo
var news_items: Array = [
	{
		"id": "cartas_pesadas_2026",
		"date": "2026-01-03",
		"title": "🔥 +50 Cartas Pesadas",
		"description": "Cartas Absurdas agora tem cartas ainda mais pesadas!",
		"icon": "🎴"
	},
	{
		"id": "modo_local_2026",
		"date": "2026-01-03",
		"title": "📱 Modo Local",
		"description": "Jogue Cartas Absurdas passando o celular!",
		"icon": "🎮"
	},
	{
		"id": "lancamento",
		"date": "2025-01-01",
		"title": "🚀 Lançamento",
		"description": "Drink's Deck está disponível!",
		"icon": "🍺"
	}
]

var seen_news: Array = []

func _ready():
	_load_seen_news()

func get_news() -> Array:
	return news_items

func get_unseen_news() -> Array:
	var unseen = []
	for news in news_items:
		if not seen_news.has(news.id):
			unseen.append(news)
	return unseen

func get_unseen_count() -> int:
	return get_unseen_news().size()

func mark_as_seen(news_id: String):
	if not seen_news.has(news_id):
		seen_news.append(news_id)
		_save_seen_news()
		news_updated.emit()

func mark_all_as_seen():
	for news in news_items:
		if not seen_news.has(news.id):
			seen_news.append(news.id)
	_save_seen_news()
	news_updated.emit()

func has_unseen_news() -> bool:
	return get_unseen_count() > 0

func _load_seen_news():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			var json = JSON.new()
			var result = json.parse(json_string)
			if result == OK:
				var data = json.get_data()
				if data.has("seen"):
					seen_news = data.seen

func _save_seen_news():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data = {"seen": seen_news}
		file.store_string(JSON.stringify(data))
		file.close()
