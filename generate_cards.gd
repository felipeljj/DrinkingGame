extends Control

var pack_state = {}

var card_data = {
	"classico": [
		"Todos os homens bebem nesta rodada.",
		"Todas as mulheres bebem nesta rodada",
		"Todos os solteiros bebem.",
		"O maior da roda, bebe.",
		"O menor da roda, bebe.",
		"Você tem imunidade no restante dessa rodada. Cada vez que você tiver que beber, deve escolher outra pessoa da roda para beber em seu lugar.",
		"[NAO LEIA EM VOZ ALTA] Peça para cada membro da roda falar um número. Quem escolher um numero par, bebe. Quem escolher um número impar, você decide a punição (use a imaginação rs)",
		"Todo mundo com idade impar, bebe.",
		"Todo mundo com idade par, bebe"
	],
	"nonsense": [
		"Imite uma girafa servindo chá. Você tem 30 segundos para convencer a roda que não deve beber. A roda decide.",
		"A partir de agora, você só deve falar as palavras de forma invertida. Por exemplo: Oi, vira iO. Se errar, bebe.",
		"Fique uma rodada inteira encarando o jogador à sua direita sem rir. Se der risada, bebe.",
		"A partir de agora, você só pode usar o banheiro de luz apagada.",
		"Faça uma dança sensual para a roda ao som de Evidencias do chitãozinho e xororó"
	],
	"weirdo": [
		"Fique 3 rodadas com seu mindinho dentro do nariz.",
		"Toda vez que alguém te perguntar algo, você deve responder e terminar com 'ain que delicia, queria mais'",
		"[NAO LEIA EM VOZ ALTA] Você deve dar 3 gritos do nada, no momento que você quiser, até o final do jogo. Em cada grito, todos na roda bebem. Não explique sua carta.",
		"Encoste seu nariz no cotovelo. Se conseguir, todos bebem. Ao contrário, você bebe.",
		"Chupe o dedão do seu pé. Ou beba 3 copos",
		"Coloque os dois dedos no ouvido, engula o cuspe, e fale 'ui que gostoso'",
		"Beba um copo de cabeça pra baixo. (faça isso fora da casa kkk)"
	],
	"languages": [
		"Cante uma música em chinês. Todos bebem e cantam juntos",
		"Recite um poema em russo. A roda vai avaliar se você deve beber ou não.",
		"A roda deve escolher um idioma para você. Você deve falar nesse idioma até o final da rodada. Se esquecer, bebe.",
		"Você tem o direito de mudar uma palavra do português. Substitua uma palavra de sua escolha, pelo que quiser. Todos devem falar corretamente após a mudança. Quem se esquecer, bebe",
		"Diga uma frase em outro idioma no ouvido do jogador à sua esquerda. Ele deve repetir para o próximo jogador, até chegar em você novamente. Se a palavra for diferente, todos bebem."
	]
}

@onready var card_panel = $CardPanel
@onready var card_label = $CardPanel/CardLabel

var displayed_texts = {}  # Dicionário para rastrear textos exibidos
var panel_freed = false  # Variável para rastrear se o painel foi removido

func _ready():
	# Inicializa o dicionário de textos exibidos para cada categoria
	for category in card_data.keys():
		displayed_texts[category] = []
	generate_card()

func generate_card():
	if panel_freed:
		return  # Se o painel foi removido, não tenta gerar mais cartas

	var available_categories = []
	
	# Adiciona as categorias ativas ao array
	for pack_name in pack_state.keys():
		if pack_state[pack_name]:
			available_categories.append(pack_name)
	
	# Remove categorias esgotadas
	available_categories = available_categories.filter(func(category):
		return card_data[category].size() != displayed_texts[category].size()
	)
	
	if available_categories.size() > 0:
		var selected_category = available_categories[randi() % available_categories.size()]
		var card_texts = card_data[selected_category]
		
		# Filtra os textos que já foram exibidos
		var unused_texts = []
		for text in card_texts:
			if text not in displayed_texts[selected_category]:
				unused_texts.append(text)
		
		if unused_texts.size() > 0:
			var selected_text = unused_texts[randi() % unused_texts.size()]
			update_card_visual(selected_category)
			
			if card_label and !panel_freed:
				card_label.text = selected_text
			
			displayed_texts[selected_category].append(selected_text)
		else:
			generate_card()  # Se a categoria esgotou, gera uma nova carta de outra categoria
	else:
		if card_label and !panel_freed:
			card_label.text = "Todas as cartas foram jogadas!"  # Mensagem opcional
		remove_card_panel()

func update_card_visual(category):
	if card_panel and !panel_freed:  # Verificar se o painel ainda existe antes de modificar a cor
		match category:
			"classico":
				card_panel.modulate = Color(1, 1, 1)  # Branco
			"nonsense":
				card_panel.modulate = Color(1, 0.392, 0.624, 1)  # Roxo
			"weirdo":
				card_panel.modulate = Color(0.351, 0.946, 0.858, 1)  # Verde
			"languages":
				card_panel.modulate = Color(0.989, 0.667, 0.411, 1)  # Laranja

func remove_card_panel():
	if card_panel:
		panel_freed = true
		card_panel.queue_free()  # Remove o painel de cartas

func _on_generate_button_pressed() -> void:
	generate_card()

func _on_sair_pressed() -> void:
	get_tree().change_scene_to_file("res://pack_selector.tscn")
