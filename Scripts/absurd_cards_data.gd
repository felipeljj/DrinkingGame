extends Node
class_name AbsurdCardsData

# Cartas PRETAS (perguntas) - O "_" indica onde vai a resposta
const BLACK_CARDS_PESADO = [
	"O que eu encontrei no porão do meu avô? ___.",
	"Qual é o segredo para um casamento feliz? ___.",
	"O que minha mãe não pode descobrir sobre mim? ___.",
	"Por que fui demitido? ___.",
	"O que o padre esconde debaixo da batina? ___.",
	"Qual foi meu presente de aniversário mais estranho? ___.",
	"O que eu faço quando ninguém está olhando? ___.",
	"Por que fui banido do grupo da família? ___.",
	"O que descobri no histórico do navegador do meu pai? ___.",
	"Qual é meu prazer culposo? ___.",
	"O que eu não deveria ter dito no velório? ___.",
	"Por que a polícia está na minha porta? ___.",
	"O que eu sonhei ontem à noite? ___.",
	"Qual é o ingrediente secreto da vovó? ___.",
	"O que eu escondi do psicólogo? ___.",
	"Por que perdi a guarda dos filhos? ___.",
	"O que eu faria por um milhão de reais? ___.",
	"Qual é a causa real do divórcio dos meus pais? ___.",
	"O que está no meu currículo secreto? ___.",
	"Por que fui expulso do Natal da família? ___.",
]

# Cartas BRANCAS (respostas)
const WHITE_CARDS_PESADO = [
	"Um anão furioso",
	"Órgãos no mercado negro",
	"A coleção de bonecas da sua tia",
	"Um pacto satânico",
	"Fotos constrangedoras",
	"O ex da sua mãe",
	"Uma seita religiosa",
	"Fetiche por pés",
	"Tráfico de memes",
	"Um altar para o Silvio Santos",
	"Canibalismo casual",
	"Fraude no INSS",
	"Um vídeo vazado",
	"Relacionamento com primos",
	"A carne de procedência duvidosa",
	"Um golpe do PIX",
	"Pensão alimentícia atrasada",
	"O corpo no quintal",
	"Furry conventions",
	"Uma tatuagem arrependida",
	"O OnlyFans da vizinha",
	"Terapia de casal",
	"Um exorcismo amador",
	"Dívidas com agiota",
	"A calcinha perdida",
	"Relacionamento aberto (sem avisar)",
	"Um vício em jogo do tigrinho",
	"A herança desviada",
	"Nudes enviados por engano",
	"Um caso com o chefe",
	"Stalker no Instagram",
	"A bebida antes das 10h",
	"Ghosting profissional",
	"Um filho secreto",
	"A desculpa do cachorro",
	"Gaslighting em família",
	"O grupo de Telegram proibido",
	"Um Tinder ativo mesmo casado",
	"A droga que 'todo mundo usa'",
	"Chantagem emocional",
	"O ex que virou cunhado",
	"Um sugar daddy",
	"A mentira no LinkedIn",
	"Daddy issues",
	"Mommy issues",
	"A terapia que não funciona",
	"Resenha de motel no Google",
	"A desculpa da academia",
	"Um podcast sobre crimes reais",
	"A amante do papai",
]

# Função para obter cartas embaralhadas
static func get_black_cards(pack: String = "pesado") -> Array:
	var cards = BLACK_CARDS_PESADO.duplicate()
	cards.shuffle()
	return cards

static func get_white_cards(pack: String = "pesado") -> Array:
	var cards = WHITE_CARDS_PESADO.duplicate()
	cards.shuffle()
	return cards

# Função para obter cartas brancas para distribuir aos jogadores
static func deal_white_cards(count: int, pack: String = "pesado") -> Array:
	var all_cards = get_white_cards(pack)
	return all_cards.slice(0, count)
