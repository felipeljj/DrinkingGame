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
@onready var generate_button = $GenerateButton

var displayed_texts = {}  # Dicionário para rastrear textos exibidos
var panel_freed = false  # Variável para rastrear se o painel foi removido

# Variáveis para gestos de deslizar
var touch_start_position = Vector2.ZERO
var is_dragging = false
var drag_threshold = 100.0  # Distância mínima para considerar como deslize
var card_original_position = Vector2.ZERO
var is_animating = false

# Variáveis para animação
var tween: Tween

# Efeitos visuais
var card_shadow: ColorRect
var original_scale = Vector2.ONE

func _ready():
	for category in card_data.keys():
		displayed_texts[category] = []
	
	if card_panel:
		card_original_position = card_panel.position
		original_scale = card_panel.scale
		_create_card_shadow()
		# Permite que o gesto de arrastar passe através do painel e do texto
		card_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	generate_card()

func _create_card_shadow():
	if not card_panel: return
	if card_shadow and is_instance_valid(card_shadow): card_shadow.queue_free()
	
	card_shadow = ColorRect.new()
	card_shadow.color = Color(0, 0, 0, 0.3)
	card_shadow.size = card_panel.size
	card_shadow.position = card_panel.position + Vector2(10, 10)
	card_shadow.z_index = card_panel.z_index - 1
	card_shadow.scale = card_panel.scale
	card_shadow.rotation = card_panel.rotation
	card_panel.get_parent().add_child(card_shadow)

func _input(event):
	if panel_freed or is_animating: return

	# Handle start of drag (touch or mouse click)
	if (event is InputEventScreenTouch and event.pressed) or \
	   (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		touch_start_position = event.position
		is_dragging = true

	# Handle end of drag (release touch or mouse click)
	elif (event is InputEventScreenTouch and not event.pressed) or \
		 (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed):
		if is_dragging:
			is_dragging = false
			_handle_swipe_gesture()

	# Handle dragging motion
	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and is_dragging and card_panel:
		var current_pos = event.position
		var drag_distance_x = current_pos.x - touch_start_position.x
		card_panel.position.x = card_original_position.x + drag_distance_x
		
		if card_shadow:
			card_shadow.position.x = card_panel.position.x + 10
			card_shadow.position.y = card_panel.position.y + 10

func _handle_swipe_gesture():
	if not card_panel: return

	var swipe_distance = card_panel.position.x - card_original_position.x
	if abs(swipe_distance) > drag_threshold:
		_animate_card_swipe(swipe_distance)
	else:
		_reset_card_position()

func _animate_card_swipe(distance):
	is_animating = true
	var direction = 1 if distance > 0 else -1
	var viewport_width = get_viewport().size.x

	if tween: tween.kill()
	tween = create_tween().set_parallel(true)
	# --- Animação de Saída ---
	tween.tween_property(card_panel, "position:x", card_original_position.x + (direction * viewport_width), 0.3)
	tween.tween_property(card_panel, "modulate:a", 0.0, 0.2)
	if card_shadow:
		tween.tween_property(card_shadow, "position:x", card_original_position.x + (direction * viewport_width), 0.3)
		tween.tween_property(card_shadow, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	
	generate_card() # Pega a próxima carta
	if panel_freed: 
		is_animating = false
		return

	# --- Preparação para Entrada ---
	card_panel.position.x = card_original_position.x - (direction * viewport_width)
	card_panel.rotation = 0.0
	card_panel.modulate.a = 0.0
	if card_shadow:
		card_shadow.position.x = card_original_position.x - (direction * viewport_width) + 10
		card_shadow.rotation = 0.0
		card_shadow.modulate.a = 0.0

	# --- Animação de Entrada ---
	tween = create_tween().set_parallel(true)
	tween.tween_property(card_panel, "position", card_original_position, 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_panel, "modulate:a", 1.0, 0.4)
	if card_shadow:
		tween.tween_property(card_shadow, "position", card_original_position + Vector2(10, 10), 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		tween.tween_property(card_shadow, "modulate:a", 0.3, 0.4)
	
	await tween.finished
	is_animating = false

func _reset_card_position():
	if not card_panel: return
	
	if tween: tween.kill()
	tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_panel, "position", card_original_position, 0.2)
	if card_shadow:
		tween.tween_property(card_shadow, "position", card_original_position + Vector2(10, 10), 0.2)

func generate_card():
	if panel_freed: return

	var available_categories = pack_state.keys().filter(func(p): return pack_state[p])
	var available_cards_exist = false
	for category in available_categories:
		if displayed_texts[category].size() < card_data[category].size():
			available_cards_exist = true
			break
	
	if available_cards_exist:
		var category
		while true:
			category = available_categories.pick_random()
			if displayed_texts[category].size() < card_data[category].size():
				break
		
		var unused_texts = card_data[category].filter(func(text): return not text in displayed_texts[category])
		var selected_text = unused_texts.pick_random()
		
		update_card_visual(category)
		if card_label and is_instance_valid(card_label):
			card_label.text = selected_text
		displayed_texts[category].append(selected_text)
	else:
		_show_end_of_cards_message()

func _show_end_of_cards_message():
	if generate_button: generate_button.visible = false
	
	# 1. Cria o rótulo
	var end_label = Label.new()
	end_label.text = "Ah não, as cartas acabaram! :("
	
	var settings = LabelSettings.new()
	settings.font_size = 60
	settings.font_color = Color("e5193f")
	settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	end_label.label_settings = settings
	
	# 2. Adiciona à cena ANTES de fazer qualquer cálculo
	add_child(end_label)
	
	# 3. Força o posicionamento manual no centro da tela
	# Espera um frame para garantir que o tamanho do rótulo foi calculado
	await get_tree().process_frame
	
	var screen_size = get_viewport_rect().size
	var label_size = end_label.size
	
	end_label.position.x = (screen_size.x - label_size.x) / 2.0
	end_label.position.y = (screen_size.y - label_size.y) / 2.0
	
	remove_card_panel()

func update_card_visual(category):
	if card_panel and !panel_freed:
		match category:
			"classico":
				card_panel.modulate = Color(1, 1, 1, 1)  # Branco
			"nonsense":
				card_panel.modulate = Color(1, 0.392, 0.624, 1)  # Rosa
			"weirdo":
				card_panel.modulate = Color(0.351, 0.946, 0.858, 1)  # Verde
			"languages":
				card_panel.modulate = Color(0.989, 0.667, 0.411, 1)  # Laranja
			"pool":
				card_panel.modulate = Color(0.688, 0.214, 0.901, 1) # Roxo
			"spicy":
				card_panel.modulate = Color(1, 0.13, 0.231, 1)
		
		if not card_shadow or not is_instance_valid(card_shadow):
			_create_card_shadow()

func remove_card_panel():
	if card_panel:
		panel_freed = true
		if card_shadow and is_instance_valid(card_shadow):
			card_shadow.queue_free()
			card_shadow = null
		card_panel.queue_free()

func _on_generate_button_pressed() -> void:
	if not is_animating:
		_animate_card_swipe(1)

func _on_sair_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/pack_selector.tscn")

func _exit_tree():
	if tween:
		tween.kill()
		tween = null
	if card_shadow and is_instance_valid(card_shadow):
		card_shadow.queue_free()
		card_shadow = null
