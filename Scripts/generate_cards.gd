extends Control

var pack_state = {}

var card_data = {
	"classico": [
		"Todos os homens bebem nesta rodada.",
		"Todas as mulheres bebem nesta rodada",
		"Todos os Não-binarios bebem nesta rodada",
		"Todos os solteiros bebem.",
		"Todos que namoram bebem",
		"O mais alto da roda, bebe.",
		"O mais baixo da roda, bebe.",
		"Você tem imunidade no restante dessa rodada. Cada vez que você tiver que beber, deve escolher outra pessoa da roda para beber em seu lugar.",
		"[NAO LEIA EM VOZ ALTA] Peça para cada membro da roda falar um número. Quem escolher um numero par, bebe. Quem escolher um número impar, você decide a punição (use a imaginação rs)",
		"Todo mundo com idade impar, bebe.",
		"Todo mundo com idade par, bebe",
		"O ultimo jogador a encostar na parede, bebe",
		"O ultimo a pegar o celular, bebe",
		"Todos os heterossexuais bebem",
		"Todos os LGTQIA+ bebem",
		"É hora de animar o jogo! Todos bebem",
		"Conte uma piada. Se a roda rir, eles bebem. Se não, você bebe",
		"Todos os fumantes, bebem.",
		"Todos os virgens, bebem.",
		"Todos que mentiram alguma vez nesse jogo, bebem",
		"Faça 10 flexões. Beba para cada flexão não feita.",
		"Faça uma pergunta no ouvido do jogador à sua direita sobre alguém da roda. A pessoa deve responder em voz alta, mas sem revelar a pergunta. Bebe quem quiser saber a pergunta.",
		"Conte uma verdade e uma mentira. Quem quiser descobrir, deve beber.",
		"Escolha um jogador para beber junto com você até o final do jogo.",
		"Livramento: utilize essa carta para se livrar de qualquer punição do jogo. Só pode ser utilizada 1 vez.",
		"Fique em silêncio absoluto até o final da rodada. Se alguém falar com você, essa pessoa bebe.",
		"Todos na roda devem substituir alguma palavra de um filme por 'cu' e dizer em voz alta. Se alguém rir, bebe."
		
	],
	"nonsense": [
		"Fique uma rodada inteira encarando o jogador à sua direita sem rir. Se der risada, bebe.",
		"A partir de agora, você só pode usar o banheiro de luz apagada.",
		"Faça uma dança sensual para a roda ao som de Evidencias do chitãozinho e xororó. Ou beba.",
		"Ande em câmera lenta até a porta e volte. Se alguém rir, essa pessoa bebe.",
		"Você está submerso de baixo da água. Fale e atue como tal. Se esquecer, bebe.",
		"Imite o som de um telefone antigo até alguém na roda fingir atender. Se ninguém atender, beba.",
		"Convide um amigo imaginário para jogar. Explique as regras para ele em 30 segundos. Você e ele bebem",
		"Fale em rimas até o final da rodada. Se esquecer, beba.",
		"Cante uma música pop conhecida, mas só pode usar a palavra 'meow'.",
		"[NÃO DEIXE OS OUTROS LER] Fale em voz alta 'GENTE! EU DUVIDO!', e fique em silencio encarando todos. Se algúem da roda dizer 'meu pau no seu ouvido', todos bebem"
	],
	"weirdo": [
		"Fique 3 rodadas com seu mindinho dentro do nariz.",
		"Toda vez que alguém te perguntar algo, você deve responder e terminar com 'ai que delicia, queria mais'",
		"[NAO LEIA EM VOZ ALTA] Você deve dar 3 gritos do nada, no momento que você quiser, até o final do jogo. Em cada grito, todos na roda bebem. Não explique sua carta.",
		"Encoste seu nariz no cotovelo. Se conseguir, todos bebem. Ao contrário, você bebe.",
		"Beba um copo de cabeça pra baixo. (faça isso fora da casa kkk)",
		"Seja um professor de yoga para um grupo de sapos imaginários e mostre a postura que eles devem fazer. Ou beba.",
		"Use um chapéu feito de papel alumínio e finja que está protegendo sua mente de invasões alienígenas. Ou beba.",
		"Faça um discurso sobre por que você deve ser eleito o 'Rei/Rainha das Baratas' e quais são suas promessas. Faça uma votação para descobrir quem na roda te elegeria. Se você perder, você bebe.",
		"Crie uma nova língua e fale um parágrafo nela para a roda. Peça para adivinharem o significado. Se a roda advinhar, você bebe. Caso contrário, todos menos você bebem.",
		"Fique sentado como se fosse uma estátua e, de vez em quando, faça movimentos inesperados. Se alguem se assustar, essa pessoa bebe. Caso contrario, você bebe. Valido a qualquer momento do jogo",
		
		
	],
	"languages": [
		"Cante uma música em chinês. Todos bebem e cantam juntos",
		"Recite um poema em russo. A roda vai avaliar se você deve beber ou não.",
		"A roda deve escolher um idioma para você. Você deve falar nesse idioma até o final da rodada. Se esquecer, bebe.",
		"Você tem o direito de mudar uma palavra do português. Substitua uma palavra de sua escolha, pelo que quiser. Todos devem falar corretamente após a mudança. Quem se esquecer, bebe",
		"Diga uma frase em outro idioma no ouvido do jogador à sua esquerda. Ele deve repetir para o próximo jogador, até chegar em você novamente. Se a palavra for diferente, todos bebem.",
		"Recite o alfabeto ao contrário, mas com sotaque estrangeiro. Se errar, beba.",
		"Apenas use palavras que começam com a letra 'S' até o próximo turno. Se errar, beba.",
		"Diga um trava-línguas em um idioma estrangeiro. Se não conseguir, beba.",
		"Fale um discurso de 20 segundos em uma língua inventada. Se alguém entender, todos bebem.",

	],
	"pool": [
		"Quem é mais provável de cometer um crime? O mais votado bebe",
		"Quem é mais provável de trair o namorado(a)? O mais votado bebe",
		"Quem é mais provável de ser um psicopata oculto? O mais votado bebe",
		"Quem é mais provável de entrar numa briga? O mais votado bebe",
		"Quem é mais provável de bater o carro? O mais votado bebe",
		"Quem é mais provável de ter um filho logo? O mais votado bebe",
		"Quem é mais provável de casar primeiro? O mais votado bebe",
		"Quem é mais pão duro? O mais votado bebe",
		"Quem é mais coração mole? O mais votado bebe",
		"Quem é mais pé no chão? O mais votado escolhe quem bebe.",
		"Quem é mais influenciavel? O mais votado bebe",
		"Quem é mais vagabundo(a)? O mais votado bebe",
		"Se você tivesse que viver o resto da vida com alguem da roda. Com quem você viveria? O mais votado bebe. Se empatar, todos bebem."
	],
	
	"spicy": [
		"Deixe um chupão na pessoa a sua direita, ou beba.",
		"Deite no colo da pessoa a sua esquerda e leve um tapa na bunda. Ou beba 3 vezes.",
		"Escolha duas pessoas para dar um beijo triplo. Ou beba 2 vezes",
		"Conte um segredo íntimo, ou beba 2 vezes.",
		"Troque uma peça de roupa com algúem, ou beba 2 vezes.",
		"Tire uma peça de roupa em 10 segundos, ou beba.",
		"Mostre seu ultimo nude pra pessoa a sua direita, ou beba 3 vezes",
		"Com os olhos vendados, toque uma parte do corpo de alguem escolhida pelo grupo (sem saber onde vai tocar), ou beba 4 vezes.",
		
		
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
				card_panel.modulate = Color(1, 0.392, 0.624, 1)  # Rosa
			"weirdo":
				card_panel.modulate = Color(0.351, 0.946, 0.858, 1)  # Verde
			"languages":
				card_panel.modulate = Color(0.989, 0.667, 0.411, 1)  # Laranja
			"pool":
				card_panel.modulate = Color(0.688, 0.214, 0.901, 1) # Roxo
			"spicy":
				card_panel.modulate = Color(1, 0.13, 0.231, 1) # Roxo

func remove_card_panel():
	if card_panel:
		panel_freed = true
		card_panel.queue_free()  # Remove o painel de cartas

func _on_generate_button_pressed() -> void:
	generate_card()

func _on_sair_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/pack_selector.tscn")
