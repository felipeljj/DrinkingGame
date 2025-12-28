extends Node
class_name PDFExporter

# Nomes dos packs
const PACK_NAMES = {
	"classico": "Classico",
	"nonsense": "Non Sense",
	"weirdo": "Weirdo",
	"languages": "Idiomas",
	"pool": "Votacao",
	"spicy": "Picante"
}

# Gerar HTML completo para impressão
static func generate_html(selected_packs: Dictionary, card_data: Dictionary) -> String:
	var html = _get_html_header()
	
	# Página 1: Capa + Tutorial + Créditos
	html += _generate_cover_page()
	
	# Coletar todas as cartas dos packs selecionados
	for pack_name in selected_packs.keys():
		if selected_packs[pack_name]:
			var all_cards = []
			# Cartas normais
			if card_data.has(pack_name):
				all_cards.append_array(card_data[pack_name])
			# Cartas raras (tratadas como normais)
			var rare_key = pack_name + "_raros"
			if card_data.has(rare_key):
				all_cards.append_array(card_data[rare_key])
			
			if all_cards.size() > 0:
				html += _generate_cards_pages(pack_name, all_cards)
	
	html += _get_html_footer()
	return html

static func _get_html_header() -> String:
	return """<!DOCTYPE html>
<html lang="pt-BR">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Drinks Deck - Cartas para Impressao</title>
	<style>
		@page {
			size: A4;
			margin: 10mm;
		}
		
		* {
			margin: 0;
			padding: 0;
			box-sizing: border-box;
		}
		
		body {
			font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
			background: white;
			color: black;
		}
		
		.page {
			width: 210mm;
			min-height: 297mm;
			padding: 10mm;
			margin: 0 auto;
			page-break-after: always;
			background: white;
			color: black;
		}
		
		.page:last-child {
			page-break-after: auto;
		}
		
		/* Capa */
		.cover {
			display: flex;
			flex-direction: column;
			align-items: center;
			justify-content: flex-start;
			padding-top: 20mm;
			text-align: center;
		}
		
		.cover .logo {
			font-size: 36pt;
			font-weight: bold;
			margin-bottom: 10mm;
			color: #FF9800;
		}
		
		.cover h1 {
			font-size: 24pt;
			color: #333;
			margin-bottom: 5mm;
		}
		
		.cover .subtitle {
			font-size: 14pt;
			color: #666;
			margin-bottom: 15mm;
		}
		
		.tutorial {
			text-align: left;
			background: #f5f5f5;
			padding: 8mm;
			border-radius: 5mm;
			margin: 0 5mm 10mm 5mm;
		}
		
		.tutorial h2 {
			font-size: 16pt;
			color: #FF9800;
			margin-bottom: 5mm;
			text-align: center;
		}
		
		.tutorial h3 {
			font-size: 12pt;
			color: #333;
			margin: 4mm 0 2mm 0;
		}
		
		.tutorial p, .tutorial li {
			font-size: 10pt;
			color: #444;
			line-height: 1.4;
			margin-bottom: 2mm;
		}
		
		.tutorial ul {
			margin-left: 5mm;
		}
		
		.credits {
			margin-top: 15mm;
			text-align: center;
			font-size: 12pt;
			color: #666;
		}
		
		/* Grid de cartas */
		.cards-grid {
			display: grid;
			grid-template-columns: repeat(3, 1fr);
			gap: 3mm;
			padding: 5mm;
		}
		
		.card {
			width: 60mm;
			height: 90mm;
			border-radius: 4mm;
			padding: 4mm;
			display: flex;
			flex-direction: column;
			justify-content: center;
			align-items: center;
			text-align: center;
			border: 0.3mm dashed #888;
			position: relative;
			font-size: 9pt;
			line-height: 1.3;
			color: black;
			background: white;
		}
		
		.card .pack-name {
			position: absolute;
			top: 2mm;
			left: 50%;
			transform: translateX(-50%);
			font-size: 7pt;
			opacity: 0.5;
			font-weight: bold;
		}
		
		.card .text {
			padding: 2mm;
			word-wrap: break-word;
			overflow-wrap: break-word;
		}
		
		/* Bordas de corte */
		.cut-guide {
			text-align: center;
			font-size: 8pt;
			color: #999;
			margin-bottom: 2mm;
		}
		
		@media print {
			body {
				background: white;
			}
			.page {
				margin: 0;
				box-shadow: none;
			}
		}
	</style>
</head>
<body>
"""

static func _generate_cover_page() -> String:
	return """
	<div class="page cover">
		<div class="logo">DRINK'S DECK</div>
		<h1>Versao para Impressao</h1>
		<p class="subtitle">Recorte as cartas e divirta-se!</p>
		
		<div class="tutorial">
			<h2>Como Jogar (Versao Fisica)</h2>
			
			<h3>Preparacao</h3>
			<ul>
				<li>Imprima as cartas em papel comum ou cartolina</li>
				<li>Recorte seguindo as linhas tracejadas</li>
				<li>Embaralhe todas as cartas</li>
				<li>Coloque o monte no centro da mesa</li>
				<li>Cada jogador precisa de sua bebida</li>
			</ul>
			
			<h3>Como Jogar</h3>
			<ul>
				<li>Jogadores sentam em circulo</li>
				<li>O mais novo comeca</li>
				<li>Em sua vez, puxe uma carta e leia em voz alta</li>
				<li>Faca o que a carta manda!</li>
				<li>Passe a vez para o proximo (sentido horario)</li>
			</ul>
			
			<h3>Simbolos Especiais</h3>
			<ul>
				<li><strong>[DADO]</strong> = Precisa de um dado</li>
				<li><strong>[ROLETA]</strong> = Gire uma garrafa ou use um app de roleta</li>
				<li><strong>[NAO LEIA ALTO!]</strong> = Leia so para voce antes de agir</li>
			</ul>
			
			<h3>Regra de Ouro</h3>
			<p style="text-align: center; font-weight: bold;">
				Beba com responsabilidade! Ninguem e obrigado a beber. 
				Substitua por agua, refrigerante ou qualquer outro desafio.
			</p>
		</div>
		
		<div class="credits">
			<p>Criado por <strong>FELIPE LATCHUK</strong></p>
		</div>
	</div>
"""

static func _generate_cards_pages(pack_name: String, cards: Array) -> String:
	var html = ""
	var cards_per_page = 9
	var page_count = ceil(float(cards.size()) / cards_per_page)
	
	var display_name = PACK_NAMES.get(pack_name, pack_name.capitalize())
	
	for page_idx in range(page_count):
		var start_idx = page_idx * cards_per_page
		var end_idx = min(start_idx + cards_per_page, cards.size())
		
		html += """
	<div class="page">
		<p class="cut-guide">Recorte nas linhas tracejadas - %s - Pagina %d/%d</p>
		<div class="cards-grid">
""" % [display_name, page_idx + 1, int(page_count)]
		
		for i in range(start_idx, end_idx):
			var card_text = _clean_card_text(cards[i])
			
			html += """
			<div class="card">
				<span class="pack-name">%s</span>
				<span class="text">%s</span>
			</div>
""" % [display_name.to_upper(), card_text]
		
		html += """
		</div>
	</div>
"""
	
	return html

static func _clean_card_text(text: String) -> String:
	# Substituir DICE por DADO e COMPASS por ROLETA
	var clean = text.replace("[DICE]", "[DADO]")
	clean = clean.replace("[COMPASS]", "[ROLETA]")
	
	# Remover emojis comuns
	var emojis = ["🌊", "🎯", "⏰", "🔄", "👽", "🌍", "🗳️", "🔥", "🎭", "⭐", "🍺", "🍻", "💀", "👑", "🎲", "🎰", "🃏", "🎴", "🎱", "🎯"]
	for emoji in emojis:
		clean = clean.replace(emoji, "")
	
	# Limpar espaços extras
	clean = clean.strip_edges()
	
	return clean

static func _get_html_footer() -> String:
	return """
</body>
</html>
"""

# Salvar HTML em arquivo e abrir no navegador
static func export_and_open(selected_packs: Dictionary, card_data: Dictionary) -> bool:
	var html = generate_html(selected_packs, card_data)
	
	# Salvar em arquivo temporário
	var file_path = "user://drinks_deck_print.html"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("[PDFExporter] Erro ao criar arquivo HTML")
		return false
	
	file.store_string(html)
	file.close()
	
	# Obter caminho absoluto
	var global_path = ProjectSettings.globalize_path(file_path)
	
	# Abrir no navegador
	OS.shell_open("file://" + global_path)
	
	print("[PDFExporter] HTML exportado para: ", global_path)
	return true
