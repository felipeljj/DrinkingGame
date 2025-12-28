extends Control

var pack_state = {}
var game_mode: String = "normal"  # Modo de jogo atual
var team_config: Dictionary = {}  # Configurações dos times

var card_data = {
	"classico_raros": [
		"🌊 CASCATA: Você começa bebendo, depois a pessoa à sua esquerda bebe, depois a próxima, e assim por diante. Você decide quando parar de beber, e só então o próximo pode parar.",
		"👉 APONTAMENTO: Na contagem de 3, todos apontam para quem acham que mais [escolha: é mais provável de casar primeiro / tem mais segredos]. Quem receber mais votos, bebe 3 vezes.",
		"🎉 DESAFIO COLETIVO: Todos da roda devem fazer 10 agachamentos JUNTOS e sincronizados. Quem errar ou desistir, bebe 2 vezes.",
		"📜 REGRA NOVA: Crie uma regra que vale até o final do jogo (ex: 'Proibido falar nomes', 'Sempre beber com a mão esquerda'). Quem quebrar, bebe!",
		"[DICE] 🎲 DADO DA SORTE: Role o dado! Resultado PAR = escolha alguém para beber o dobro. ÍMPAR = você bebe o resultado.",
		"⚡ TWIST CARD: TUDO INVERTE! Nas próximas 3 cartas, quem DEVERIA beber NÃO bebe, e todos os outros bebem no lugar.",
		"⏰ DESAFIO RELÂMPAGO: Em 15 segundos, todos devem dizer o nome de uma capital. Quem repetir ou não falar, bebe!",
		"[COMPASS] TROCA DE COPOS: Gire a roleta. Você deve trocar seu copo (e o conteúdo dele) com a pessoa apontada. Se um copo estiver cheio e o outro vazio... azar.",
		"[DICE] O DADO MESTRE: Role o dado. O número que sair é o seu Número Mestre até sua próxima rodada. Toda vez que qualquer jogador rolar esse número em qualquer dado, você pode mandar alguém (à sua escolha) beber 3 goles.",
		" O DITADOR. Até sua próxima rodada, você é o Ditador. Você pode vetar qualquer ação, criar uma regra temporária ou mandar alguém beber (limite de 3 ordens).",
		"[DICE] DADO INVERTIDO: Role o dado. 1 = Distribua 6 goles. 2 = Distribua 5. 3 = Distribua 4. 4 = Beba 3. 5 = Beba 2. 6 = Beba 1.",
		"[COMPASS] A GRANDE TROCA: Gire a roleta. Você deve trocar seu assento, seu copo E seu celular com a pessoa apontada por 1 rodada inteira.",
		"ANISTIA. Guarde esta carta. Use-a para cancelar os efeitos de uma carta RARA (sua ou de outra pessoa) assim que ela for lida. A carta é descartada e o jogo segue."
	],
	"classico": [
		"[DICE] Role o dado. Beba o número de goles que sair",
		"Rima Forçada. Diga uma frase (ex: Eu gosto de pão). O jogador à esquerda deve dizer uma frase que rime (ex: mas gosto mais de macarrão). Continuem até alguém travar ou repetir. Quem travar, bebe 2 vezes.",
		"[DICE] DUELO DE DADOS: Escolha um oponente. Ambos rolam o dado. Quem tirar o número menor, bebe a diferença entre os dois dados. (Ex: 5 e 2. O jogador que tirou 2, bebe 3 goles).",
		"GUARDIÃO DA CHAVE: Você é o guardião. Ninguém pode ir ao banheiro sem a sua permissão. Você pode cobrar o pedagio que quiser (Um gole, 1 elogio, 1 verdade..)",
		"[COMPASS] Roleta da Memória: Gire a roleta. A pessoa apontada começa o jogo (Fui ao bar e comprei..) Ela diz um item (ex: uma cerveja). O próximo repete e adiciona (...uma cerveja e um amendoim). Quem errar a sequência, bebe 3.",
		"Distribua 3 goles como quiser",
		"[DICE] 6 é Salvação: Role o dado. Se cair 1, 2, 3, 4 ou 5, beba esse número de goles. Se cair 6, você está salvo e manda o jogador à sua esquerda beber 6 goles.",
		"Todos os homens bebem nesta rodada.",
		"Todas as mulheres bebem nesta rodada",
		"Todos os Não-binarios bebem nesta rodada",
		"Todos os solteiros bebem.",
		"Todos que namoram bebem",
		"O mais alto da roda, bebe.",
		"O mais baixo da roda, bebe.",
		"Você tem imunidade no restante dessa rodada. Cada vez que você tiver que beber, deve escolher outra pessoa da roda para beber em seu lugar.",
		"[NÃO LEIA ALTO!] Peça para cada membro da roda falar um número. Quem escolher um numero par, bebe. Quem escolher um número impar, você decide a punição (use a imaginação rs)",
		"Todo mundo com idade impar, bebe.",
		"Todo mundo com idade par, bebe",
		"O ultimo jogador a encostar na parede, bebe",
		"O ultimo a pegar o celular, bebe",
		"Todos os heterossexuais bebem",
		"Todos os LGTQIA+ bebem",
		"Beber é bom demais. Todos bebem",
		"Conte uma piada. Se a roda rir, eles bebem. Se não, você bebe",
		"Todos os fumantes, bebem.",
		"Todos os virgens, bebem.",
		"Todos que mentiram alguma vez nesse jogo, bebem",
		"Faça 10 flexões. Beba para cada flexão não feita.",
		"Faça uma pergunta no ouvido do jogador à sua direita sobre alguém da roda. A pessoa deve responder em voz alta, mas sem revelar a pergunta. Bebe quem quiser saber a pergunta.",
		"Conte 2 verdades e uma mentira. Quem quiser descobrir, deve beber.",
		"Escolha um jogador para beber junto com você até o final do jogo.",
		"Livramento: utilize essa carta para se livrar de qualquer punição do jogo. Só pode ser utilizada 1 vez.",
		"Fique em silêncio absoluto até o final da rodada. Se alguém falar com você, você volta a falar, e essa pessoa bebe.",
		"Todos na roda devem substituir alguma palavra de um filme por 'cu' e dizer em voz alta. Se alguém rir, bebe.",
		"[DICE] Role o dado! Número de goles que a pessoa à sua esquerda deve beber.",
		"[COMPASS] Gire a roleta! A pessoa apontada deve fazer 5 polichinelos ou beber 2 vezes.",
		"[COMPASS] O Elogio Falso: Gire. A pessoa apontada deve te fazer um elogio que soe verdadeiro, mas é uma mentira. Se o grupo acreditar, você bebe. Se o grupo não acreditar, a pessoa bebe.",
		"O Historiador: Resuma o que aconteceu no jogo desde o início. Beba 1 gole para cada fato importante que você esquecer (decidido pela roda).",
		"O DJ: Você controla a música pelas próximas 3 músicas. Se alguém reclamar da sua escolha, essa pessoa bebe 1.",
		"O Brinde Sincero: Faça um brinde sincero (não pode ser zoeira) a alguém da roda. Todos bebem 1 em homenagem.",
		"[DICE] Par ou Ímpar Solidário: Escolha um jogador. Role o dado. Se cair o que você escolheu (par/ímpar), vocês dois distribuem 2 goles. Se errar, vocês dois bebem 2.",
		"O Último a...: Diga 'O último a [ação bizarra, ex: 'ficar num pé só'] bebe!'. O último a completar, bebe 3.",
		"O Copo do Rei (Início): Todos colocam um pouquinho da sua bebida num copo central. Quem tirar a próxima carta RARA, bebe o copo todo.",
		"[DICE] A MALDIÇÃO DO DADO: Role o dado. O número que sair é a 'Maldição'. O próximo jogador que rolar esse número (por qualquer motivo) bebe um shot.",
		"O VOTO DE SILÊNCIO: Você deve ficar em silêncio absoluto. A primeira pessoa que falar com você (e você responder) bebe 3 goles. A primeira pessoa que fizer você rir, bebe 3 goles. Vale até sua próxima rodada.",
		"[COMPASS] A TROCA DE PODER: Gire a roleta. Você e a pessoa apontada trocam de cartas da mão (se tiverem). Se não tiverem, você 'rouba' a próxima rodada dela. Ela joga, mas você decide tudo por ela.",
		"[DICE] DADO SOCIAL: Role o dado. 1-2: Beba 1. 3-4: Distribua 2. 5-6: Todos bebem 1.",
		"O Desafio do Equilíbrio: Fique em um pé só enquanto bebe seu próximo gole. Se desequilibrar, beba mais um.",
		"O Elo Mais Fraco: Aponte para o jogador que você acha que está mais bêbado. Esse jogador deve beber 1 gole para provar que aguenta.",
		"O Elo Mais Forte: Aponte para o jogador mais sóbrio. Esse jogador deve beber 2 goles para alcançar os outros.",
		"[COMPASS] A Flecha Envenenada: Gire. A pessoa apontada bebe 1 gole. O jogador à esquerda dela bebe 2. O jogador à esquerda deste, bebe 3.",
		"O Último a Rir: Conte uma piada muito ruim. O último a rir (ou o primeiro a rir, se ninguém rir), bebe 2. Se ninguem rir, você bebe 3 vezes.",
		"Parceiro de Copo: Escolha um jogador. Pelas próximas 3 rodadas, você só pode beber *depois* que ele beber. Se você beber antes, beba em dobro.",
		"[DICE] O Dado Vidente: Antes de rolar, adivinhe se o número será 'Alto' (4,5,6) ou 'Baixo' (1,2,3). Se acertar, distribua 3. Se errar, beba 3."
	],
	"nonsense_raros": [
		"🔄 TROCA LOUCA: Todos na roda devem trocar de lugar AGORA! Último a sentar bebe 2 vezes e deve imitar um golfinho por 1 rodada.",
		"[COMPASS] 🎯 ROLETA DA ZOEIRA: Gire a roleta! A pessoa apontada deve fazer uma imitação de alguém da roda. Se a roda adivinhar quem é em 30s, a pessoa imitada bebe. Se não, quem imitou bebe.",
		"🌀 REALIDADE ALTERNATIVA: Até a próxima rodada, você vive em câmera lenta. Tudo que fizer deve ser devagar. Se esquecer, bebe e todos riem de você.",
		"[DICE] 🎲Role o dado! 1-2: Você vira um ET e só fala 'bip bop'. 3-4: Você é um robô com movimentos travados. 5-6: Você é um passarinho. Vale por 1 rodada!",
		"MUNDO OPOSTO. Por 2 rodadas completas, TUDO é o oposto. 'Sim' é 'não', 'beber' é 'distribuir', 'esquerda' é 'direita'. Quem se confundir, bebe 2.",
		" [DICE] O DADO ATOR: Role o dado. 1: Câmera Lenta. 2: Câmera Rápida (x2). 3: Mudo. 4: Ópera (cante tudo). 5: Robô. 6: Dinossauro. Atue assim até sua próxima rodada.",
		" A REBELDIA DAS MÁQUINAS. Todos os celulares devem ser colocados no centro. O primeiro a pegar o celular (mesmo que toque) antes do fim do jogo, bebe 5 goles."
	],
	"nonsense": [
		"Fique uma rodada inteira encarando o jogador à sua direita sem rir. Se der risada, bebe.",
		"Você deve narrar as ações do jogador à sua esquerda em terceira pessoa, como um documentário da National Geographic. (Ex: E aqui vemos a espécie... ela levanta o copo, cautelosa...). Vale por 1 rodada. Se você parar ou rir, bebe 2",
		"A partir de agora, você só pode usar o banheiro de luz apagada.",
		"Role o dado. 1-3: Você só pode falar sem mover os lábios por 2 rodadas. 4-6: Você só pode falar em sussurros. Se errar, bebe.",
		"[COMPASS] MARIONETE HUMANA: Gire a roleta. A pessoa apontada é sua marionete por 60 segundos. Você deve posicioná-la (sem falar) em uma pose bizarra. Ela deve ficar parada. Se ela rir ou se mover, ela bebe 2. Se você não conseguir uma pose engraçada, você bebe.",
		"Faça uma dança sensual para a roda ao som de Evidencias do chitãozinho e xororó. Ou beba.",
		"Você está submerso de baixo da água. Fale e atue como tal. Se esquecer, bebe.",
		"[COMPASS] TROCA DE PERSONALIDADE: Gire a roleta. Você e a pessoa apontada devem trocar de personalidade. Você deve agir como ela e ela como você (jeito de falar, manias). O primeiro a quebrar o personagem ou rir, bebe 3. Vale por 2 rodadas.",
		"Imite o som de um telefone antigo até alguém na roda fingir atender. Se ninguém atender, beba.",
		"Fale em rimas por 5 minutos. Se esquecer ou errar, bebe.",
		"Cante uma música pop conhecida, mas só pode usar a palavra 'meow'.",
		"[NÃO DEIXE OS OUTROS LER] Fale em voz alta 'GENTE! EU DUVIDO!', e fique em silencio encarando todos. Se algúem da roda dizer 'meu pau no seu ouvido', todos bebem",
		"O Pinguim: Você só pode andar com os joelhos juntos e braços colados ao corpo (como um pinguim) até sua próxima rodada. Se esquecer, bebe.",
		"Monólogo Interno: Fale todos os seus pensamentos em voz alta por 1 rodada. ('Nossa, que carta idiota. Será que estou falando alto?'). Se parar, bebe 2.",
		"[DICE] O Escultor: Role o dado. O número é a quantidade de pessoas (incluindo você) que devem formar uma 'escultura humana' bizarra. Fiquem assim por 30s. Quem rir ou cair, bebe.",
		"O Tradutor de Cão: Fale apenas latindo por 1 rodada. O jogador à sua esquerda deve 'traduzir' o que você quer dizer. Se o tradutor rir, ele bebe. Se você falar, você bebe.",
		"A ORQUESTRA: Você é o maestro. Aponte para um jogador, ele deve fazer um som de animal. Aponte para outro, ele faz outro som. Você deve reger uma 'música' por 30s. Quem rir ou errar o som, bebe 2.",
		"[DICE] O DADO TEATRAL: Role o dado. Você deve falar TUDO em forma de: 1-2: Ópera (cantando). 3-4: Sussurro (como um segredo). 5-6: Grito (como um anúncio). Vale por 2 rodadas.",
		"O MUNDO EM CÂMERA LENTA: ATENÇÃO! A partir de agora e por 2 minutos, TODOS os jogadores (incluindo você) devem agir e falar em câmera lenta. O primeiro a esquecer e agir normal, bebe 3.",
		"[COMPASS] O IMITADOR: Gire. A pessoa apontada deve escolher alguém da roda para você imitar (sem ser ela). Você deve imitar a pessoa até o grupo adivinhar quem é. Se não adivinharem em 1 min, você bebe 3.",
		"O Robô: Fale como um robô (voz metalizada e movimentos travados) até sua próxima rodada. Se quebrar o personagem, bebe 1.",
		"Mãos para Trás: Beba seu próximo gole com as mãos para trás (sem usar as mãos para pegar o copo).",
		"[DICE] A Dancinha: Role o dado. O número é a quantidade de segundos (x5) que você deve fazer a dança mais ridícula que conseguir (Ex: 3 = 15 segundos).",
		"O Anunciante: Fale como um locutor de rádio ou de propaganda de TV por 1 rodada inteira.",
		"A Galinha: Você deve cacarejar (em vez de rir) toda vez que achar algo engraçado. Vale por 2 rodadas. Se rir normal, bebe 1.",
		"O Chão é Ácido: Ninguém pode colocar o copo no chão. O primeiro a colocar o copo no chão (e não na mesa, balcão, etc), bebe 2. Vale até sua próxima rodada."

	],
	"weirdo_raros": [
		"👽 INVASÃO ALIENÍGENA: [COMPASS] Use a roleta! A pessoa apontada foi abduzida. Ela deve falar em uma 'língua alienígena' por 2 rodadas. Se falar português, bebe!",
		"🎭 PERSONALIDADE ALEATÓRIA: [DICE] Role o dado! 1-2: Você é um bebê chorão. 3-4: Você é um idoso ranzinza. 5-6: Você é um esquerdo macho performático. Atue assim até alguém te fazer rir. Se rir, bebe!",
		"🤪 CARTA LOUCURA: Todos devem sussurrar uma ação aleatória no ouvido da pessoa à direita. Na contagem de 3, TODOS fazem a ação que ouviram. Quem não fizer, bebe 3 vezes.",
		"⏰ DESAFIO DA ESTÁTUA: Fique congelado como estátua por 20 segundos. Qualquer movimento = 1 gole. ",
		"O CONTRATO: Escolha 2 jogadores (não pode ser você). Eles devem dar as mãos. Eles estão presos. Eles só podem soltar as mãos se ambos concordarem em beber 3 goles cada. Vale até um deles beber por outro motivo.",
		"A SEITA. Inicie sua seita. Crie um nome (ex: 'Filhos do Copo Vazio') e um gesto. A qualquer momento, você pode fazer o gesto. O último da roda a repetir o gesto, bebe 2. Vale até o fim do jogo.",
		"[DICE] DADO DA POSSESSÃO: Role o dado. 1-3: O jogador à sua direita te 'possui' e escolhe uma personalidade para você (ex: 'criança mimada') por 2 rodadas. 4-6: Você 'possui' o jogador à sua esquerda.",
	],
	"weirdo": [
		"Fique 3 rodadas com seu mindinho dentro do nariz.",
		"Toda vez que alguém te perguntar algo, você deve responder e terminar com 'ai que delicia, queria mais'",
		"[COMPASS] Gire. Você e a pessoa apontada devem se encarar sem piscar. O primeiro a piscar, beber ou rir, bebe 3 goles.",
		"Encoste seu nariz no cotovelo. Se conseguir, todos bebem. Ao contrário, você bebe.",
		"Beba um copo de cabeça pra baixo. (faça isso fora da casa kkk)",
		"Crie uma nova língua e fale um parágrafo nela para a roda. Peça para adivinharem o significado. Se a roda advinhar, você bebe. Caso contrário, todos menos você bebem.",
		"Fique sentado como se fosse uma estátua e, de vez em quando, faça movimentos inesperados. Se alguem se assustar, essa pessoa bebe. Caso contrario, você bebe. Valido a qualquer momento do jogo",
		"jogador à sua esquerda só pode falar em gugu-datês (linguagem de bebê). Você deve traduzir seriamente o que ele diz para o grupo. Se um de vocês rir, ambos bebem 2. Vale por 1 rodada.",
		"O Cheirador: Vende os olhos. A roda escolhe 3 objetos aleatórios. Você deve adivinhar o que são apenas pelo cheiro. Beba 1 gole para cada erro.",
		"O Gêmeo Sombra: Escolha um jogador. Você deve copiar *exatamente* tudo que ele fizer (beber, coçar, falar) com 1 segundo de atraso. Vale por 2 rodadas. Se errar, bebe 1.",
		"[DICE] O Dado Sensorial: Role o dado. 1-2: Beba 1 gole de olhos vendados. 3-4: Beba 1 gole tampando o nariz. 5-6: Beba 1 gole com a mão trocada.",
		"A Múmia: Peça para ser enrolado em papel higiênico (ou similar). Fique assim por 1 rodada. Se não quiser, beba 4.",
		"O UNIVERSO PARALELO: Escolha uma regra bizarra da física (ex: 'A gravidade agora puxa para o lado'). Todos devem fingir que essa regra é real por 1 rodada. Quem não atuar direito, bebe 2.",
		"A TERCEIRA PESSOA: Por 3 rodadas, NINGUÉM pode usar as palavras 'Eu', 'Meu', 'Minha'. Deve-se falar na terceira pessoa (ex: 'O [Seu Nome] vai beber'). Quem errar, bebe 1.",
		"[DICE] O Dado Tátil: Role o dado. Você deve beber seu próximo gole enquanto toca um objeto com uma textura estranha (ex: par=parede, impar=cabelo de alguém).",
		"Mão Trocada: Se você é destro, faça tudo com a mão esquerda (beber, pegar cartas). Se é canhoto, use a direita. Vale por 2 rodadas. Se errar, bebe 1.",

	],
	"languages_raros": [
		"🌍 TORRE DE BABEL: [COMPASS] Gire a roleta! Cada pessoa apontada deve falar uma frase em idioma diferente (português não vale!). Quem não souber, bebe 2 vezes.",
		"📞 TELEFONE SEM FIO GLOBAL: Sussurre uma frase em inglês no ouvido da pessoa à esquerda. Ela traduz e passa adiante em outro idioma. No final, compare com o original. Se mudou muito, todos bebem!",
		"[DICE] 🎲 DADO POLIGLOTA: Role o dado! Conte uma história de 30 segundos misturando ESSE número de idiomas diferentes. Não conseguiu? Bebe o número do dado.",
		"🗣️ KARAOKÊ INTERNACIONAL: Cante 30 segundos de uma música famosa em um sotaque estrangeiro escolhido pela roda. Se a roda rir demais, todos bebem. Se não rir, você bebe.",
		"⏰ DESAFIO RÁPIDO: 30 segundos para todos dizerem 'EU TE AMO' em idiomas diferentes. Quem repetir ou não conseguir, bebe!",
		"🎭 ATUAÇÃO MUDA: Sem falar NADA, atue uma cena famosa de filme. Roda tem 40s para adivinhar. Acertou? Você bebe. Errou? Todos bebem."
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
		" O FILÓLOGO. Escolha uma palavra MUITO comum (ex: 'eu', 'sim', 'beber'). Ninguém pode falar essa palavra. Quem falar, bebe 1 gole. A regra vale por 3 rodadas completas.",
		"[DICE] DADO POLIGLOTA EXTREMO: Role o dado. Você deve xingar o jogador à sua esquerda no número de idiomas do dado. (Pode inventar). Se ele rir, ele bebe. Se ele ficar ofendido, você bebe.",
		"[COMPASS] A ONU: Gire. A pessoa apontada é o 'Delegado'. Ela escolhe um país. Pelas próximas 2 rodadas, todos devem tratar essa pessoa como se ela fosse a líder daquele país (com sotaque, reverência, etc.). Quem quebrar o personagem, bebe 2.",
		"O Sotaque: Escolha um sotaque (ex: Português de Portugal, Russo, Caipira). Fale assim até sua próxima rodada. Se esquecer, bebe 1.",
		"Mímica de Expressão: Tente mimetizar uma expressão idiomática (ex: 'Chutar o balde', 'Acabar em pizza'). Se o grupo não adivinhar em 30s, você bebe 2.",
		"[DICE] O Dicionário: Role o dado. Você deve falar o número de sinônimos de uma palavra escolhida pela roda (ex: 'Grande'). Falhou? Beba 2.",
		"O Rapper: Você deve anunciar a próxima carta ou o próximo jogador fazendo uma rima de rap.",
		"Google Tradutor Fail: Diga uma expressão em português (ex: 'Matar cachorro a grito'). O jogador à esquerda traduz literalmente para o inglês ('Kill dog by screaming'). Se a roda rir, o tradutor está salvo. Se não, ele bebe.",
		"O Jogo do 'A': Fale por 30 segundos sobre qualquer tema, mas sem usar palavras que tenham a letra 'A'. Se usar, bebe 3."

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
		"Se você tivesse que viver o resto da vida com alguem da roda. Com quem você viveria? O mais votado bebe. Se empatar, todos bebem.",
		"VOTO CEGO: Todos fecham os olhos menos você. Diga algo como: Quem acha que X deve fazer X? Vota-se levantando a mão. Se a maioria votar, a ação deve ser cumprida, ou beber 5 vezes",
		"[COMPASS] ALIANÇA: Gire a roleta. Na proxima votação, se você e a pessoa apontada votarem na mesma pessoa, os seus votos valem como se fossem 4 votos.",
		"O MÁRTIR. Votação: 'Quem é o jogador mais injustiçado do jogo?'. O mais votado ganha esta carta. Pode usá-la 1 vez para forçar *outra* pessoa a beber no seu lugar.",
		"[COMPASS] A ALIANÇA FORÇADA: Gire DUAS vezes. As duas pessoas apontadas estão em uma aliança. Na próxima votação (POOL), elas *devem* votar na mesma pessoa. Se não entrarem em acordo em 10s, ambas bebem 3.",
		" VOTO CEGO. Todos fecham os olhos. Você faz uma pergunta 'Quem é o mais...'. Na contagem de 3, todos apontam. Ao abrir os olhos, quem tiver mais dedos apontados para si, bebe 4.",
	],
	"pool_raros": [
		"[DICE] 🎲 VOTAÇÃO: Role o dado! Esse é o número de rodadas de votação que farão AGORA. Temas livres! Quem for mais votado em cada rodada, bebe.",
		"⚖️ TRIBUNAL DO CAOS: Votem na pessoa 'mais provável de sobreviver a um apocalipse zumbi'. Quem ganhar escolhe 2 pessoas para 'morrer' (beber 2 vezes cada).",
		"💫 INVERSÃO TOTAL: Votem em 'quem é MENOS provável de [tema à escolha]'. Dessa vez, quem receber MENOS votos (mais normal) é quem bebe!"
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
		"Sente no colo de alguém da roda até a próxima rodada. Ou beba 2 vezes.",
		"Faça uma dança sensual para a pessoa que o grupo escolher. Ou beba 3 vezes.",
		"Deixe alguém da roda escrever algo na sua pele com caneta. Ou beba 2 vezes.",
		"Escolha alguém para te dar 3 beijinhos no pescoço. Ou beba 2 vezes.",
		"Conte a última fantasia sexual que você teve. Ou beba 3 vezes.",
		"Fique abraçado com a pessoa a sua esquerda por 3 rodadas. Se soltarem antes, ambos bebem.",
		"Sussure algo picante no ouvido de alguém da roda. Ou beba 2 vezes.",
		"Verdade ou consequência: responda sinceramente uma pergunta picante OU cumpra um desafio escolhido pelo grupo.",
		"Mande um áudio gemendo para o último contato do WhatsApp. Ou beba 4 vezes.",
		"Escolha alguém para sentar entre suas pernas até o final da rodada. Ou beba 2 vezes.",
		"O APAGÃO. As luzes se apagam por 10 segundos. Faça o que quiser (beijar, trocar de lugar, beliscar...). Quando as luzes acenderem, todos que mudaram de lugar ou estão rindo, bebem 2.",
		"[DICE] DADO DO STRIP TOTAL: Role o dado. O número que sair é o *total* de peças de roupa que o GRUPO INTEIRO deve tirar (distribuído como quiserem. Ex: 6 = 6 pessoas tiram 1, ou 1 pessoa tira 6).",
		"[COMPASS] ROLETA DO CASAL: Gire. A pessoa apontada e você são um 'casal' por 3 rodadas. Devem sentar juntos (colo, abraçados) e se alguém pedir 'beija!', devem dar um selinho. Recusou? Ambos bebem 5.",
		" VERDADE COLETIVA. Todos escrevem uma pergunta picante anônima. Os papéis são misturados. Você sorteia uma e a lê em voz alta. TODOS da roda devem responder (ou beber 3).",
		"Top 3: Diga seu 'Top 3 pessoas da roda que você pegaria'. Se não houver 3, complete com celebridades. Beba 2 se gaguejar.",
		"O Detalhe: Descreva em detalhes o que você acha mais sexy na pessoa à sua esquerda. Ou beba 3.",
		"[DICE] O Dado Sensual: Role o dado. 1-3: Dê um selinho na pessoa à direita. 4-6: Dê uma mordidinha leve no ombro da pessoa à esquerda. (Recusou? Beba 4).",
		"Body Shot: Escolha alguém. Beba um gole do umbigo ou pescoço dessa pessoa. (Recusou? Ambos bebem 4).",
		"[COMPASS] O Fetiche: Gire. A pessoa apontada deve confessar um fetiche que ela tem. Se não confessar, bebe 3.",
		"Lamber ou Beber: O grupo escolhe um local em você (ex: cotovelo, joelho, etc..). A pessoa à sua direita deve lamber. Se ela recusar, ela bebe 3. Se você recusar, você bebe 3.",
		"Eu Já : Diga 'Eu já [algo picante]'. Todos que *também* já fizeram, bebem 1. Se *ninguém* beber, você bebe 3.",
		"Posição Favorita: Descreva sua posição sexual favorita usando apenas mímica. Se o grupo não adivinhar, beba 2."
	],
	"spicy_raros": [
		"[COMPASS] 💋 BEIJO DA ROLETA: Gire a roleta! A pessoa apontada e você devem dar um beijo. Tipo do beijo: a roda decide (selinho, francês, esquimó, etc). Recusou? Ambos bebem 4 vezes.",
		"[DICE] 🎲 VERDADE OU CONSEQUÊNCIA EXTREMO: Role o dado! 1-3: Responda uma verdade MUITO picante. 4-6: Cumpra uma consequência escolhida pelo grupo. Recusou? Bebe o dobro do número e fica de fora por 2 rodadas.",
		"💏 TROCA DE CASAIS: Se houver casais na roda, troquem os pares por 3 rodadas! Solteiros escolhem duplas. Ações em dupla valem nesse período.",
		"⏰ 7 MINUTOS NO CÉU: Você e a pessoa mais votada pela roda vão para outro cômodo por 45 segundos. O que acontecer lá, fica lá... Ou não. Roda decide se contam o que rolou. Recusaram? Bebem 5 vezes CADA."
	]
}

@onready var card_panel = $CardPanel
@onready var card_label = $CardPanel/CardLabel
@onready var generate_button = $GenerateButton

var displayed_texts = {}  # Dicionário para rastrear textos exibidos
var panel_freed = false  # Variável para rastrear se o painel foi removido

# Sistema de filtros
var active_filters: Array[String] = []  # ["simple", "heavy", "interactive", "rare"]
var card_metadata: Dictionary = {}  # Metadados das cartas (tags)

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

# Timer e alarme
var timer_overlay: Control
var attention_timer: float = 0.0
var attention_threshold: float = 60.0  # 60 segundos
var is_showing_attention_alert: bool = false

# Ferramentas (dado e bússola)
var dice_roller: Control
var compass_spinner: Control
var mode_info_ui: Label
var custom_colors := {}

# Histórico de cartas
var card_history: Array = []
var current_history_index: int = -1  # -1 significa que estamos na carta atual (não no histórico)

# Fotos da sessão
var session_photos: Array = []

# Tempo de sessão
var session_start_time: int = 0

# Sistema de veto (mantido para compatibilidade, mas botão removido)
var veto_used: bool = false
@onready var history_button = $TopButtons/Historico
# Botões opcionais (podem não existir em versões antigas da cena)
@onready var photo_button: Button = $TopButtons/Foto if has_node("TopButtons/Foto") else null
@onready var tools_button = $ToolsButton
var current_card_requires_tool: String = ""  # "dice", "compass", ou ""

func _ready():
	# Manter tela sempre ligada durante o jogo
	DisplayServer.screen_set_keep_on(true)
	
	# Registrar início da sessão
	session_start_time = Time.get_ticks_msec()
	
	# Carregar cartas traduzidas do LocalizationManager
	_load_translated_cards()
	
	for category in card_data.keys():
		displayed_texts[category] = []
	
	if card_panel:
		card_original_position = card_panel.position
		original_scale = card_panel.scale
		_create_card_shadow()
		# Permite que o gesto de arrastar passe através do painel e do texto
		# EXCETO pelo tools_button que precisa receber cliques
		card_panel.mouse_filter = Control.MOUSE_FILTER_PASS
		card_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Instanciar timer overlay
	var timer_scene = load("res://Scenes/timer_overlay.tscn")
	timer_overlay = timer_scene.instantiate()
	add_child(timer_overlay)
	timer_overlay.z_index = 100
	
	# Instanciar dado
	var dice_scene = load("res://Scenes/dice_roller.tscn")
	if dice_scene:
		dice_roller = dice_scene.instantiate()
		add_child(dice_roller)
		dice_roller.z_index = 101
	
	# Instanciar bússola
	var compass_scene = load("res://Scenes/compass_spinner.tscn")
	if compass_scene:
		compass_spinner = compass_scene.instantiate()
		add_child(compass_spinner)
		compass_spinner.z_index = 101
	
	# Conectar botões opcionais (se ainda não conectados)
	if photo_button and not photo_button.pressed.is_connected(_on_foto_pressed):
		photo_button.pressed.connect(_on_foto_pressed)
	
	# Carregar packs customizados selecionados
	_load_custom_card_data()
	
	# Carregar filtros passados da tela de filtros (se não foram passados, usar salvos)
	if active_filters.is_empty():
		_load_saved_filters()
	
	# Gerar metadados para todas as cartas (incluindo customizadas)
	_generate_card_metadata()
	
	# Garantir que todas categorias existentes em card_data tenham lista de exibidas inicializada
	for category in card_data.keys():
		if not displayed_texts.has(category):
			displayed_texts[category] = []
	
	# Info de modo
	_show_mode_info()
	
	# Adicionar hover effects nos botões
	if history_button:
		UIManager.add_button_hover_effect(history_button)
	if photo_button:
		UIManager.add_button_hover_effect(photo_button)
	if tools_button:
		tools_button.visible = false  # Começar invisível
		tools_button.z_index = 200  # MUITO acima de outros elementos
		tools_button.mouse_filter = Control.MOUSE_FILTER_STOP  # Garantir que recebe cliques
		# Garantir que o botão seja clicável
		tools_button.disabled = false
		tools_button.focus_mode = Control.FOCUS_NONE
		# Forçar o botão a estar na frente
		tools_button.set_process_mode(Node.PROCESS_MODE_ALWAYS)
		UIManager.add_button_hover_effect(tools_button)
		print("🔧 ToolsButton inicializado: z_index=", tools_button.z_index, " disabled=", tools_button.disabled, " mouse_filter=", tools_button.mouse_filter)
	
	# Traduzir botão Sair
	if has_node("Sair"):
		_update_sair_button()
		UIManager.add_button_hover_effect($Sair)
	
	# Conectar signal de mudança de idioma
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_update_ui_texts)
	
	# Aplicar glassmorphism nos botões do topo
	_apply_glassmorphism_to_top_buttons()
	
	generate_card()

func _process(delta: float):
	if panel_freed or is_animating:
		return
	
	# Alarme de atenção
	attention_timer += delta
	if attention_timer >= attention_threshold and not is_showing_attention_alert:
		_show_attention_alert()

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

	if not is_instance_valid(card_panel) or not card_panel.is_inside_tree():
		is_animating = false
		return

	if tween and is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	if not tween:
		is_animating = false
		return
	tween.set_parallel(true)
	# --- Animação de Saída ---
	tween.tween_property(card_panel, "position:x", card_original_position.x + (direction * viewport_width), 0.3)
	tween.tween_property(card_panel, "modulate:a", 0.0, 0.2)
	if card_shadow and is_instance_valid(card_shadow):
		tween.tween_property(card_shadow, "position:x", card_original_position.x + (direction * viewport_width), 0.3)
		tween.tween_property(card_shadow, "modulate:a", 0.0, 0.2)
	
	await tween.finished
	
	if panel_freed or not is_instance_valid(card_panel):
		is_animating = false
		return
	
	# SWIPE ESQUERDA (distance < 0): Avançar para NOVA carta
	# SWIPE DIREITA (distance > 0): Voltar para carta ANTERIOR
	if distance < 0:
		# Swipe para esquerda -> nova carta
		current_history_index = -1  # Reset ao índice atual
		generate_card()
	else:
		# Swipe para direita -> carta anterior
		_show_previous_card()
	
	if panel_freed: 
		is_animating = false
		return

	# --- Preparação para Entrada ---
	if not is_instance_valid(card_panel):
		is_animating = false
		return
		
	card_panel.position.x = card_original_position.x - (direction * viewport_width)
	card_panel.rotation = 0.0
	card_panel.modulate.a = 0.0
	if card_shadow and is_instance_valid(card_shadow):
		card_shadow.position.x = card_original_position.x - (direction * viewport_width) + 10
		card_shadow.rotation = 0.0
		card_shadow.modulate.a = 0.0

	# --- Animação de Entrada ---
	if not is_instance_valid(card_panel) or not card_panel.is_inside_tree():
		is_animating = false
		return
		
	tween = create_tween()
	if not tween:
		is_animating = false
		return
	tween.set_parallel(true)
	tween.tween_property(card_panel, "position", card_original_position, 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_panel, "modulate:a", 1.0, 0.4)
	if card_shadow and is_instance_valid(card_shadow):
		tween.tween_property(card_shadow, "position", card_original_position + Vector2(10, 10), 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		tween.tween_property(card_shadow, "modulate:a", 0.3, 0.4)
	
	await tween.finished
	is_animating = false

func _show_previous_card():
	# Verificar se há cartas anteriores no histórico
	if card_history.is_empty():
		return
	
	# Se já estamos no histórico, voltar uma posição
	if current_history_index == -1:
		# Primeira vez voltando: ir para a penúltima carta (a última é a atual)
		if card_history.size() >= 2:
			current_history_index = card_history.size() - 2
		else:
			return  # Só tem uma carta, não dá para voltar
	else:
		# Já estamos navegando: voltar mais uma
		if current_history_index > 0:
			current_history_index -= 1
		else:
			return  # Já está na primeira carta
	
	# Exibir carta do histórico
	var history_card = card_history[current_history_index]
	
	# Atualizar visual
	update_card_visual(history_card.category)
	if card_label and is_instance_valid(card_label):
		var processed_text = _process_card_markers(history_card.text)
		card_label.text = processed_text
		_adjust_card_text_size()
	
	# Detectar ferramenta (se houver)
	current_card_requires_tool = _detect_required_tool(history_card.text)
	_update_tools_button()
	
	# Mostrar indicador de raridade se necessário
	_hide_rare_indicator()
	if history_card.get("is_rare", false):
		_show_rare_indicator()

func _reset_card_position():
	if not card_panel or not is_instance_valid(card_panel) or not card_panel.is_inside_tree():
		return
	
	if tween and is_instance_valid(tween):
		tween.kill()
	tween = create_tween()
	if not tween:
		return
	tween.set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(card_panel, "position", card_original_position, 0.2)
	if card_shadow and is_instance_valid(card_shadow):
		tween.tween_property(card_shadow, "position", card_original_position + Vector2(10, 10), 0.2)

func generate_card():
	if panel_freed: return
	
	# Resetar alarme de atenção
	attention_timer = 0.0
	is_showing_attention_alert = false

	var available_categories = pack_state.keys().filter(func(p): return pack_state[p])
	var available_cards_exist = false
	for category in available_categories:
		if card_data.has(category):
			if not displayed_texts.has(category):
				displayed_texts[category] = []
		if displayed_texts[category].size() < card_data[category].size():
			available_cards_exist = true
			break
	
	# Se não há cartas disponíveis e repetição está permitida, resetar histórico
	if not available_cards_exist and UIManager.is_card_repeat_allowed():
		# Limpar histórico de cartas exibidas para permitir repetição
		for category in displayed_texts.keys():
			displayed_texts[category] = []
		available_cards_exist = true
	
	if available_cards_exist:
		var category
		var is_rare = false
		
		# Decidir se é carta rara (7% de chance)
		if randf() < 0.07:
			is_rare = true
		
		# Selecionar categoria
		while true:
			var base_category = available_categories.pick_random()
			if not card_data.has(base_category):
				continue
			var rare_category = base_category + "_raros"
			
			# Tentar pegar carta rara se disponível
			if is_rare and rare_category in card_data:
				if displayed_texts.has(rare_category):
					if displayed_texts[rare_category].size() < card_data[rare_category].size():
						category = rare_category
						break
				else:
					displayed_texts[rare_category] = []
					category = rare_category
					break
			
			# Pegar carta normal
			if not displayed_texts.has(base_category):
				displayed_texts[base_category] = []
			if displayed_texts[base_category].size() < card_data[base_category].size():
				category = base_category
				is_rare = false
				break
		
		# Pegar texto aleatório da categoria (aplicando filtros)
		var available_cards = _filter_cards(category)
		var unused_texts = available_cards.filter(func(text): return not text in displayed_texts[category])
		
		# Se não há cartas disponíveis após filtros, usar todas
		if unused_texts.is_empty():
			unused_texts = card_data[category].filter(func(text): return not text in displayed_texts[category])
		
		var selected_text = unused_texts.pick_random()
		
		# Animação especial para carta rara
		if is_rare:
			_show_rare_card_animation()
			# Verificar conquistas de cartas raras
			_check_rare_achievements()
		
		update_card_visual(category)
		if card_label and is_instance_valid(card_label):
			# Detectar qual ferramenta é necessária (antes de processar)
			current_card_requires_tool = _detect_required_tool(selected_text)
			
			# Processar marcadores antes de exibir
			var processed_text = _process_card_markers(selected_text)
			card_label.text = processed_text
			
			# Ajustar tamanho do texto automaticamente
			_adjust_card_text_size()
		
		# Mostrar/esconder botão de ferramentas baseado na carta
		_update_tools_button()
		
		# Mostrar/esconder indicador de raraF
		_hide_rare_indicator()
		if is_rare:
			_show_rare_indicator()
		
		# Adicionar ao histórico
		card_history.append({
			"text": selected_text,
			"category": category,
			"timestamp": Time.get_ticks_msec(),
			"is_rare": is_rare
		})
		
		displayed_texts[category].append(selected_text)
		
		# Verificar se pack foi zerado
		_check_pack_completion(category)
		
		# Verificar se todas as cartas foram zeradas
		_check_all_cards_completion()
		
		# Verificar "Perfeccionista" após verificar pack
		_check_perfectionist_achievement()
	else:
		_show_end_of_cards_message()
		# Verificar conquista de zerar todas as cartas
		_check_all_cards_completion()

func _detect_required_tool(text: String) -> String:
	# Detectar qual ferramenta a carta requer
	if "[DICE]" in text:
		return "dice"
	elif "[COMPASS]" in text:
		return "compass"
	return ""

func _update_tools_button():
	if not tools_button or not is_instance_valid(tools_button):
		return
	
	# Mostrar botão apenas se a carta requer uma ferramenta
	if current_card_requires_tool != "":
		tools_button.visible = true
		tools_button.disabled = false
		tools_button.mouse_filter = Control.MOUSE_FILTER_STOP
		tools_button.z_index = 200  # Garantir que está acima de tudo
		tools_button.set_process_mode(Node.PROCESS_MODE_ALWAYS)
		
		# Ajustar posições: mover generate_button para a esquerda e tools_button para a direita
		if generate_button and is_instance_valid(generate_button):
			generate_button.offset_left = -210.0
			generate_button.offset_right = 56.0
		
		tools_button.offset_left = 76.0
		tools_button.offset_right = 316.0
		tools_button.offset_top = -496.0
		tools_button.offset_bottom = -316.0
		
		# Mover o botão para o topo da hierarquia de renderização
		if tools_button.get_parent():
			tools_button.get_parent().move_child(tools_button, -1)  # Move para o final (renderiza por último)
		
		# Atualizar ícone e texto do botão
		match current_card_requires_tool:
			"dice":
				tools_button.text = ""
				tools_button.icon = load("res://icons/dice.svg")
				tools_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				tools_button.expand_icon = true
				print("Botao de dado atualizado com SVG - z_index: ", tools_button.z_index)
			"compass":
				tools_button.text = ""
				tools_button.icon = load("res://icons/roleta.svg")
				tools_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				tools_button.expand_icon = true
				print("Botao de compasso atualizado com SVG - z_index: ", tools_button.z_index)
		
		# Forçar atualização do layout
		await get_tree().process_frame
		if is_instance_valid(tools_button):
			tools_button.queue_redraw()
	else:
		tools_button.visible = false
		
		# Restaurar posição central do generate_button
		if generate_button and is_instance_valid(generate_button):
			generate_button.offset_left = -132.0
			generate_button.offset_right = 134.0

func _process_card_markers(text: String) -> String:
	var processed = text
	
	# Detectar marcador [TIMER:X]
	var timer_regex = RegEx.new()
	timer_regex.compile("\\[TIMER:(\\d+)\\]")
	var timer_match = timer_regex.search(processed)
	
	if timer_match:
		var seconds = int(timer_match.get_string(1))
		processed = processed.replace(timer_match.get_string(), "")
		# Iniciar timer após cooldown de 10s
		if timer_overlay:
			timer_overlay.start_timer(seconds, 10.0)
	
	
	# Remover marcadores [DICE] e [COMPASS] (não abrem mais automaticamente)
	if "[DICE]" in processed:
		processed = processed.replace("[DICE]", "")
	
	if "[COMPASS]" in processed:
		processed = processed.replace("[COMPASS]", "")
	
	return processed.strip_edges()

func _show_end_of_cards_message():
	if generate_button: generate_button.visible = false
	
	# 1. Cria o rótulo
	var end_label = Label.new()
	end_label.text = LocalizationManager.translate("cards_end_message", "Ah não, as cartas acabaram! :(")
	
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
	end_label.position.y = (screen_size.y - label_size.y) / 2.0 - 100
	
	# 4. Criar botões de ação
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 50)
	add_child(button_container)
	
	# Botão Reiniciar
	var restart_button = Button.new()
	restart_button.text = LocalizationManager.translate("cards_restart", "Reiniciar")
	restart_button.add_theme_font_size_override("font_size", 50)
	restart_button.custom_minimum_size = Vector2(300, 80)
	restart_button.flat = true
	restart_button.pressed.connect(_on_restart_pressed)
	button_container.add_child(restart_button)
	
	# Botão Voltar ao Menu
	var menu_button = Button.new()
	menu_button.text = LocalizationManager.translate("cards_menu", "Menu")
	menu_button.add_theme_font_size_override("font_size", 50)
	menu_button.custom_minimum_size = Vector2(300, 80)
	menu_button.flat = true
	menu_button.pressed.connect(_on_sair_pressed)
	button_container.add_child(menu_button)
	
	await get_tree().process_frame
	button_container.position.x = (screen_size.x - button_container.size.x) / 2.0
	button_container.position.y = end_label.position.y + 150
	
	remove_card_panel()

func _on_restart_pressed():
	# Resetar histórico de cartas exibidas
	for category in card_data.keys():
		displayed_texts[category] = []
	
	# Recarregar a cena
	get_tree().reload_current_scene()

func _show_rare_card_animation():
	# Vibrar forte
	UIManager.safe_vibrate(500)
	
	# Criar efeito de brilho dourado
	var shine_overlay = ColorRect.new()
	shine_overlay.color = Color(1, 0.843, 0, 0.4)  # Dourado
	shine_overlay.size = get_viewport_rect().size
	shine_overlay.z_index = 98
	add_child(shine_overlay)
	
	# Animar brilho
	if not is_instance_valid(shine_overlay) or not shine_overlay.is_inside_tree():
		return
	var shine_tween = create_tween()
	if shine_tween:
		shine_tween.tween_property(shine_overlay, "modulate:a", 0.0, 0.5)
		shine_tween.tween_property(shine_overlay, "modulate:a", 1.0, 0.5)
		shine_tween.tween_property(shine_overlay, "modulate:a", 0.0, 0.5)
		await shine_tween.finished
	if is_instance_valid(shine_overlay):
		shine_overlay.queue_free()
	
	# Mostrar label "CARTA RARA!"
	var rare_label = Label.new()
	rare_label.text = LocalizationManager.translate("notification_rare_card", "CARTA RARA!")
	var settings = LabelSettings.new()
	settings.font_size = 70
	settings.font_color = Color(1, 0.843, 0, 1)  # Dourado
	settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	settings.outline_size = 10
	settings.outline_color = Color.BLACK
	rare_label.label_settings = settings
	rare_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rare_label.z_index = 150
	
	add_child(rare_label)
	
	await get_tree().process_frame
	var screen_size = get_viewport_rect().size
	rare_label.position = Vector2((screen_size.x - rare_label.size.x) / 2.0, 250)
	
	# Animar label
	if not is_instance_valid(rare_label) or not rare_label.is_inside_tree():
		return
	rare_label.modulate.a = 0.0
	rare_label.scale = Vector2(0.5, 0.5)
	var label_tween = create_tween()
	if label_tween:
		label_tween.set_parallel(true)
		label_tween.tween_property(rare_label, "modulate:a", 1.0, 0.4)
		label_tween.tween_property(rare_label, "scale", Vector2(1.2, 1.2), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		await get_tree().create_timer(2.0).timeout
		
		if is_instance_valid(rare_label) and rare_label.is_inside_tree():
			label_tween = create_tween()
			if label_tween:
				label_tween.tween_property(rare_label, "modulate:a", 0.0, 0.5)
				await label_tween.finished
		
		if is_instance_valid(rare_label):
			rare_label.queue_free()

func _show_attention_alert():
	is_showing_attention_alert = true
	
	# Vibrar celular
	UIManager.safe_vibrate(500)
	
	# Criar efeito de piscar na tela
	var flash_overlay = ColorRect.new()
	flash_overlay.color = Color(1, 0, 0, 0.3)
	flash_overlay.size = get_viewport_rect().size
	flash_overlay.z_index = 99
	add_child(flash_overlay)
	
	# Animar piscar
	if not is_instance_valid(flash_overlay) or not flash_overlay.is_inside_tree():
		return
	var flash_tween = create_tween()
	if flash_tween:
		flash_tween.tween_property(flash_overlay, "modulate:a", 0.0, 0.3)
		flash_tween.tween_property(flash_overlay, "modulate:a", 1.0, 0.3)
		flash_tween.tween_property(flash_overlay, "modulate:a", 0.0, 0.3)
		await flash_tween.finished
	if is_instance_valid(flash_overlay):
		flash_overlay.queue_free()
	
	# Mostrar mensagem
	var alert_label = Label.new()
	alert_label.text = LocalizationManager.translate("notification_attention", "Vamos lá, decidam logo!")
	
	var settings = LabelSettings.new()
	settings.font_size = 50
	settings.font_color = Color("e5193f")
	settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	settings.outline_size = 5
	settings.outline_color = Color.BLACK
	alert_label.label_settings = settings
	alert_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alert_label.z_index = 100
	
	add_child(alert_label)
	
	await get_tree().process_frame
	var screen_size = get_viewport_rect().size
	alert_label.position = Vector2((screen_size.x - alert_label.size.x) / 2.0, 100)
	
	# Animar mensagem
	if not is_instance_valid(alert_label) or not alert_label.is_inside_tree():
		return
	alert_label.modulate.a = 0.0
	var msg_tween = create_tween()
	if msg_tween:
		msg_tween.tween_property(alert_label, "modulate:a", 1.0, 0.5)
		await get_tree().create_timer(3.0).timeout
		if is_instance_valid(alert_label) and alert_label.is_inside_tree():
			msg_tween = create_tween()
			if msg_tween:
				msg_tween.tween_property(alert_label, "modulate:a", 0.0, 0.5)
				await msg_tween.finished
		
		if is_instance_valid(alert_label):
			alert_label.queue_free()

func update_card_visual(category):
	if card_panel and !panel_freed:
		match category:
			"classico":
				card_panel.modulate = Color(1, 1, 1, 1)  # Branco
			"classico_raros":
				card_panel.modulate = Color(1, 0.95, 0.6, 1)
			"nonsense":
				card_panel.modulate = Color(1, 0.392, 0.624, 1)  # Rosa
			"nonsense_raros":
				card_panel.modulate = Color(1, 0.6, 0.76, 1)
			"weirdo":
				card_panel.modulate = Color(0.351, 0.946, 0.858, 1)  # Verde
			"weirdo_raros":
				card_panel.modulate = Color(0.5, 1, 0.9, 1)
			"languages":
				card_panel.modulate = Color(0.989, 0.667, 0.411, 1)  # Laranja
			"languages_raros":
				card_panel.modulate = Color(1, 0.8, 0.55, 1)
			"pool":
				card_panel.modulate = Color(0.688, 0.214, 0.901, 1) # Roxo
			"spicy":
				card_panel.modulate = Color(1, 0.13, 0.231, 1)
			"pool_raros":
				card_panel.modulate = Color(0.8, 0.4, 1, 1)
			"spicy_raros":
				card_panel.modulate = Color(1, 0.4, 0.45, 1)
			_:
				# Packs customizados
				if custom_colors.has(category):
					card_panel.modulate = custom_colors[category]
		
		if not card_shadow or not is_instance_valid(card_shadow):
			_create_card_shadow()

func _load_translated_cards():
	# Carregar cartas traduzidas do LocalizationManager
	if not LocalizationManager:
		return
	
	var categories = ["classico", "classico_raros", "nonsense", "nonsense_raros", 
					  "weirdo", "weirdo_raros", "languages", "languages_raros", 
					  "pool", "pool_raros", "spicy", "spicy_raros"]
	
	for category in categories:
		var translated_cards = LocalizationManager.get_cards(category)
		if translated_cards.size() > 0:
			card_data[category] = translated_cards
		# Se não houver tradução, mantém o card_data original (fallback)

func _generate_card_metadata():
	# Gerar metadados (tags) para todas as cartas
	card_metadata.clear()
	
	for category in card_data.keys():
		card_metadata[category] = []
		for text in card_data[category]:
			var tags: Array[String] = []
			
			# Classificar teor (simple ou heavy)
			var theory = _classify_card_theory(text, category)
			tags.append(theory)
			
			# Verificar se é interativa
			if "[DICE]" in text or "[COMPASS]" in text:
				tags.append("interactive")
			
			# Verificar se é rara
			if category.ends_with("_raros"):
				tags.append("rare")
			
			card_metadata[category].append(tags)

func _classify_card_theory(text: String, category: String) -> String:
	# Classificar cartas como "simple" (leve) ou "heavy" (pesado) baseado no conteúdo
	
	# Pack Spicy é sempre pesado
	if category.begins_with("spicy"):
		return "heavy"
	
	# Palavras-chave que indicam conteúdo pesado
	var heavy_keywords = [
		"chupão", "chupetón", "hickey",
		"nude", "desnudo", "naked",
		"beijo", "beso", "kiss",
		"secreto íntimo", "secret íntimo", "secreto íntimo",
		"fantasia sexual", "sexual fantasy", "fantasía sexual",
		"troque de roupa", "change clothes", "cambiar ropa",
		"tire uma peça", "remove a piece", "quitar una pieza",
		"fetiche", "fetish",
		"body shot", "bebida do umbigo", "bebida del ombligo",
		"lamber", "lick", "lamer",
		"7 minutos no céu", "7 minutes in heaven", "7 minutos en el cielo",
		"apagão", "blackout", "apagón",
		"strip", "desnudarse",
		"casal", "couple", "pareja",
		"beijo triplo", "triple kiss", "beso triple",
		"tapa na bunda", "spank", "nalgada",
		"sentar entre pernas", "sit between legs", "sentarse entre piernas",
		"gemendo", "moaning", "gimiendo",
		"posição sexual", "sexual position", "posición sexual"
	]
	
	var text_lower = text.to_lower()
	for keyword in heavy_keywords:
		if keyword in text_lower:
			return "heavy"
	
	# Se não encontrou palavras pesadas, é simples
	return "simple"

func _filter_cards(category: String) -> Array:
	# Retornar apenas cartas que passam nos filtros ativos
	if not card_data.has(category):
		return []
	
	if active_filters.is_empty():
		# Sem filtros, retornar todas
		return card_data[category]
	
	var filtered_cards = []
	var metadata = card_metadata.get(category, [])
	
	for i in range(card_data[category].size()):
		var card_text = card_data[category][i]
		var card_tags = metadata[i] if i < metadata.size() else []
		
		# Verificar se a carta passa em pelo menos um filtro ativo
		var passes_filter = false
		for filter_tag in active_filters:
			if filter_tag in card_tags:
				passes_filter = true
				break
		
		if passes_filter:
			filtered_cards.append(card_text)
	
	return filtered_cards

func _load_custom_card_data():
	var file_path = "user://custom_packs.json"
	if not FileAccess.file_exists(file_path):
		return
	var f = FileAccess.open(file_path, FileAccess.READ)
	if not f:
		return
	var txt = f.get_as_text()
	f.close()
	var data = JSON.parse_string(txt)
	if typeof(data) == TYPE_DICTIONARY and data.has("packs"):
		for p in data.packs:
			var id: String = "custom_" + (p.get("name", "Pack") as String)
			var cards = p.get("cards", [])
			if typeof(cards) == TYPE_ARRAY and cards.size() > 0:
				card_data[id] = cards
				if not displayed_texts.has(id):
					displayed_texts[id] = []
				custom_colors[id] = Color(p.get("color", "#888888"))

func _apply_glassmorphism_to_top_buttons():
	# Aplicar estilo glassmorphism nos botões do topo
	var buttons = [history_button, photo_button]
	
	for btn in buttons:
		if btn and is_instance_valid(btn):
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.1, 0.1, 0.1, 0.7)
			style.set_corner_radius_all(15)
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.border_color = Color(1, 1, 1, 0.2)
			style.shadow_size = 10
			style.shadow_color = Color(0, 0, 0, 0.5)
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_stylebox_override("hover", style)
			btn.add_theme_stylebox_override("pressed", style)

func _show_rare_indicator():
	# Criar estrela dourada no canto da carta
	var star = Label.new()
	star.text = "*"
	star.name = "RareIndicator"
	var star_settings = LabelSettings.new()
	star_settings.font_size = 80
	star.label_settings = star_settings
	star.z_index = 50
	
	if card_panel:
		card_panel.add_child(star)
		star.position = Vector2(card_panel.size.x - 120, 20)
		
		# Animação de rotação e brilho
		var tween = star.create_tween().set_loops()
		tween.tween_property(star, "rotation_degrees", 360, 3.0).from(0)
		tween.tween_property(star, "scale", Vector2(1.2, 1.2), 1.5)
		tween.tween_property(star, "scale", Vector2(0.8, 0.8), 1.5)

func _hide_rare_indicator():
	if card_panel and card_panel.has_node("RareIndicator"):
		var star = card_panel.get_node("RareIndicator")
		star.queue_free()

func _adjust_card_text_size():
	# Auto-ajustar tamanho da fonte se texto for muito longo
	if not card_label:
		return
	
	var text_length = card_label.text.length()
	var label_settings = card_label.label_settings
	
	# Tamanhos base
	var base_size: int
	if text_length > 250:
		base_size = 45
	elif text_length > 180:
		base_size = 50
	elif text_length > 120:
		base_size = 55
	else:
		base_size = 60
	
	# Aplicar multiplicador de tamanho de fonte
	var multiplier = UIManager.get_font_size_multiplier()
	label_settings.font_size = int(base_size * multiplier)

func _update_ui_texts():
	# Atualizar textos traduzidos quando o idioma mudar
	_update_sair_button()

func _update_sair_button():
	# Traduzir botão Sair
	if has_node("Sair"):
		$Sair.text = LocalizationManager.translate("game_exit_button", "SAIR")

func _show_mode_info():
	# Renderizar uma faixa no topo com informações do modo
	var info = ""
	if game_mode == "times" and team_config.get("enabled", false):
		var names: Array = team_config.get("team_names", [])
		var team_names_str = ", ".join(names)
		info = LocalizationManager.translate("game_mode_teams_info", "Modo TIMES: %s") % team_names_str
	
	if info != "":
		var lbl = Label.new()
		var ls = LabelSettings.new()
		ls.font_size = 30
		ls.font_color = Color("ffd93d")
		ls.outline_size = 4
		ls.outline_color = Color.BLACK
		lbl.label_settings = ls
		lbl.text = info
		mode_info_ui = lbl
		add_child(lbl)
		await get_tree().process_frame
		lbl.position = Vector2(40, 120)

func remove_card_panel():
	if card_panel:
		panel_freed = true
		if card_shadow and is_instance_valid(card_shadow):
			card_shadow.queue_free()
			card_shadow = null
		card_panel.queue_free()

func _on_generate_button_pressed() -> void:
	if not is_animating:
		_animate_card_swipe(-1)

func _on_sair_pressed() -> void:
	# Wrapped temporariamente desativado - voltar ao menu
	UIManager.change_scene_with_fade("res://Scenes/menu.tscn")

func _on_historico_pressed() -> void:
	_show_history_modal()

func _on_foto_pressed() -> void:
	_capture_photo()

func _on_tools_button_pressed() -> void:
	print("🔧 ToolsButton pressionado! Ferramenta requerida: ", current_card_requires_tool)
	print("🔧 Botão z_index: ", tools_button.z_index if tools_button else "N/A")
	print("🔧 Botão disabled: ", tools_button.disabled if tools_button else "N/A")
	print("🔧 Botão mouse_filter: ", tools_button.mouse_filter if tools_button else "N/A")
	
	# Abrir diretamente a ferramenta necessária
	match current_card_requires_tool:
		"dice":
			print("Tentando abrir dado...")
			if dice_roller and is_instance_valid(dice_roller):
				print("✅ Dice roller encontrado, chamando show_dice()")
				dice_roller.show_dice()
			else:
				print("❌ Dice roller não encontrado ou inválido")
				# Tentar criar se não existir
				if not dice_roller:
					var dice_scene = load("res://Scenes/dice_roller.tscn")
					if dice_scene:
						dice_roller = dice_scene.instantiate()
						add_child(dice_roller)
						dice_roller.show_dice()
		"compass":
			print("Tentando abrir compasso...")
			if compass_spinner and is_instance_valid(compass_spinner):
				print("✅ Compass spinner encontrado, chamando show_compass()")
				compass_spinner.show_compass()
			else:
				print("❌ Compass spinner não encontrado ou inválido")
				# Tentar criar se não existir
				if not compass_spinner:
					var compass_scene = load("res://Scenes/compass_spinner.tscn")
					if compass_scene:
						compass_spinner = compass_scene.instantiate()
						add_child(compass_spinner)
						compass_spinner.show_compass()
		_:
			print("Nenhuma ferramenta especifica detectada, mostrando menu")
			# Fallback: mostrar menu se não detectou ferramenta
			_show_tools_menu()

# Métodos auxiliares para o debug menu
func _open_compass():
	if compass_spinner:
		compass_spinner.show_compass()

func _open_dice():
	if dice_roller:
		dice_roller.show_dice()

func _open_timer():
	if timer_overlay:
		timer_overlay.start_timer(60, 0)

func _show_tools_menu():
	# Criar modal de fundo
	var modal_bg = ColorRect.new()
	modal_bg.color = Color(0, 0, 0, 0.7)
	modal_bg.size = get_viewport_rect().size
	modal_bg.z_index = 150
	modal_bg.name = "ToolsModalBG"
	add_child(modal_bg)
	
	# Fechar ao clicar no fundo
	var bg_ref = weakref(modal_bg)
	modal_bg.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if bg_ref.get_ref() and is_instance_valid(bg_ref.get_ref()):
				_close_tools_menu()
	)
	
	# Painel de ferramentas
	var tools_panel = Panel.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.15, 0.95)
	panel_style.set_corner_radius_all(25)
	panel_style.border_color = Color(1, 0.7, 0.2, 0.8)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	tools_panel.add_theme_stylebox_override("panel", panel_style)
	tools_panel.custom_minimum_size = Vector2(600, 500)
	tools_panel.position = Vector2(164, 790)
	tools_panel.z_index = 151
	tools_panel.name = "ToolsPanel"
	add_child(tools_panel)
	
	# Container vertical
	var vbox = VBoxContainer.new()
	vbox.size = tools_panel.size
	vbox.add_theme_constant_override("separation", 20)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tools_panel.add_child(vbox)
	
	# Título
	var title = Label.new()
	title.text = LocalizationManager.translate("game_tools_title", "FERRAMENTAS")
	var title_settings = LabelSettings.new()
	title_settings.font_size = 50
	title_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	title.label_settings = title_settings
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Botões de ferramentas
	var compass_btn = Button.new()
	compass_btn.custom_minimum_size = Vector2(500, 100)
	compass_btn.text = LocalizationManager.translate("game_tools_compass", "ROLETA")
	var compass_style = StyleBoxFlat.new()
	compass_style.bg_color = Color(0.2, 0.2, 0.2, 1)
	compass_style.set_corner_radius_all(15)
	compass_btn.add_theme_stylebox_override("normal", compass_style)
	compass_btn.add_theme_stylebox_override("hover", compass_style)
	compass_btn.add_theme_stylebox_override("pressed", compass_style)
	compass_btn.add_theme_font_size_override("font_size", 45)
	var compass_ref = weakref(compass_spinner)
	compass_btn.pressed.connect(func():
		_close_tools_menu()
		if compass_ref.get_ref() and is_instance_valid(compass_ref.get_ref()):
			compass_ref.get_ref().show_compass()
	)
	vbox.add_child(compass_btn)
	
	var dice_btn = Button.new()
	dice_btn.custom_minimum_size = Vector2(500, 100)
	dice_btn.text = LocalizationManager.translate("game_tools_dice", "DADOS")
	var dice_style = StyleBoxFlat.new()
	dice_style.bg_color = Color(0.2, 0.2, 0.2, 1)
	dice_style.set_corner_radius_all(15)
	dice_btn.add_theme_stylebox_override("normal", dice_style)
	dice_btn.add_theme_stylebox_override("hover", dice_style)
	dice_btn.add_theme_stylebox_override("pressed", dice_style)
	dice_btn.add_theme_font_size_override("font_size", 45)
	var dice_ref = weakref(dice_roller)
	dice_btn.pressed.connect(func():
		_close_tools_menu()
		if dice_ref.get_ref() and is_instance_valid(dice_ref.get_ref()):
			dice_ref.get_ref().show_dice()
	)
	vbox.add_child(dice_btn)
	
	# Botão fechar
	var close_btn = Button.new()
	close_btn.custom_minimum_size = Vector2(500, 80)
	close_btn.text = LocalizationManager.translate("game_tools_close", "FECHAR")
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.3, 0.1, 0.1, 1)
	close_style.set_corner_radius_all(15)
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_stylebox_override("hover", close_style)
	close_btn.add_theme_stylebox_override("pressed", close_style)
	close_btn.add_theme_font_size_override("font_size", 40)
	close_btn.pressed.connect(_close_tools_menu)
	vbox.add_child(close_btn)
	
	# Adicionar hover effects
	UIManager.add_button_hover_effect(compass_btn)
	UIManager.add_button_hover_effect(dice_btn)
	UIManager.add_button_hover_effect(close_btn)
	
	# Animar entrada
	tools_panel.modulate.a = 0.0
	tools_panel.scale = Vector2(0.8, 0.8)
	var tween = tools_panel.create_tween()
	if tween:
		tween.set_parallel(true)
		tween.tween_property(tools_panel, "modulate:a", 1.0, 0.3)
		tween.tween_property(tools_panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	UIManager.safe_vibrate(50)

func _close_tools_menu():
	var bg = get_node_or_null("ToolsModalBG")
	var panel = get_node_or_null("ToolsPanel")
	
	if panel and is_instance_valid(panel):
		var tween = panel.create_tween()
		if tween:
			tween.set_parallel(true)
			tween.tween_property(panel, "modulate:a", 0.0, 0.2)
			tween.tween_property(panel, "scale", Vector2(0.8, 0.8), 0.2)
			await tween.finished
	
	if bg and is_instance_valid(bg):
		bg.queue_free()
	if panel and is_instance_valid(panel):
		panel.queue_free()

func _on_finalizar_pressed() -> void:
	_show_wrapped_report()

func _on_veto_pressed() -> void:
	if veto_used:
		_show_veto_already_used_message()
		return
	
	# Mostrar confirmação
	_show_veto_confirmation()

func _show_veto_confirmation():
	# Criar modal de confirmação
	var modal_bg = ColorRect.new()
	modal_bg.color = Color(0, 0, 0, 0.8)
	modal_bg.size = get_viewport_rect().size
	modal_bg.z_index = 200
	add_child(modal_bg)
	
	var confirm_panel = Panel.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 1)
	panel_style.set_corner_radius_all(20)
	confirm_panel.add_theme_stylebox_override("panel", panel_style)
	confirm_panel.custom_minimum_size = Vector2(700, 400)
	confirm_panel.position = Vector2(190, 760)
	confirm_panel.z_index = 201
	add_child(confirm_panel)
	
	var vbox = VBoxContainer.new()
	vbox.size = confirm_panel.size
	vbox.add_theme_constant_override("separation", 30)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	confirm_panel.add_child(vbox)
	
	# Mensagem
	var message = Label.new()
	var veto_title = LocalizationManager.translate("game_veto_confirm_title", "Usar seu único veto?")
	var veto_message = LocalizationManager.translate("game_veto_confirm_message", "(O grupo deve controlar!)")
	message.text = veto_title + "\n\n" + veto_message
	var msg_settings = LabelSettings.new()
	msg_settings.font_size = 40
	msg_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	message.label_settings = msg_settings
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(message)
	
	# Botões
	var btn_container = HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_container.add_theme_constant_override("separation", 40)
	vbox.add_child(btn_container)
	
	var confirm_btn = Button.new()
	confirm_btn.text = LocalizationManager.translate("game_veto_confirm_yes", "✓ SIM")
	confirm_btn.add_theme_font_size_override("font_size", 45)
	confirm_btn.custom_minimum_size = Vector2(250, 80)
	confirm_btn.flat = true
	btn_container.add_child(confirm_btn)
	
	var cancel_btn = Button.new()
	cancel_btn.text = LocalizationManager.translate("game_veto_confirm_no", "✗ NÃO")
	cancel_btn.add_theme_font_size_override("font_size", 45)
	cancel_btn.custom_minimum_size = Vector2(250, 80)
	cancel_btn.flat = true
	btn_container.add_child(cancel_btn)
	
	confirm_btn.pressed.connect(func():
		modal_bg.queue_free()
		confirm_panel.queue_free()
		_use_veto()
	)
	
	cancel_btn.pressed.connect(func():
		modal_bg.queue_free()
		confirm_panel.queue_free()
	)

func _use_veto():
	veto_used = true
	
	# Botão veto removido - não precisa atualizar visual
	
	# Vibrar
	UIManager.safe_vibrate(200)
	
	# Confete vermelho
	ParticlesManager.create_confetti(self, get_viewport_rect().size / 2, Color(0.9, 0.1, 0.1, 1), 50)
	
	# Mostrar mensagem
	var veto_label = Label.new()
	veto_label.text = LocalizationManager.translate("notification_veto_used", "CARTA VETADA!")
	var settings = LabelSettings.new()
	settings.font_size = 70
	settings.font_color = Color("e5193f")
	settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	settings.outline_size = 8
	settings.outline_color = Color.BLACK
	veto_label.label_settings = settings
	veto_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	veto_label.z_index = 150
	
	add_child(veto_label)
	
	await get_tree().process_frame
	var screen_size = get_viewport_rect().size
	veto_label.position = Vector2((screen_size.x - veto_label.size.x) / 2.0, 200)
	
	# Animar
	if not is_instance_valid(veto_label) or not veto_label.is_inside_tree():
		return
	veto_label.modulate.a = 0.0
	veto_label.scale = Vector2(0.5, 0.5)
	var veto_tween = create_tween()
	if veto_tween:
		veto_tween.set_parallel(true)
		veto_tween.tween_property(veto_label, "modulate:a", 1.0, 0.3)
		veto_tween.tween_property(veto_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		await get_tree().create_timer(2.0).timeout
		
		if is_instance_valid(veto_label) and veto_label.is_inside_tree():
			veto_tween = create_tween()
			if veto_tween:
				veto_tween.tween_property(veto_label, "modulate:a", 0.0, 0.5)
				await veto_tween.finished
		
		if is_instance_valid(veto_label):
			veto_label.queue_free()
	
	# Gerar próxima carta
	_animate_card_swipe(1)

func _show_veto_already_used_message():
	var alert = Label.new()
	alert.text = LocalizationManager.translate("notification_veto_already_used", "Veto já foi usado!")
	var settings = LabelSettings.new()
	settings.font_size = 45
	settings.font_color = Color("e5193f")
	settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	alert.label_settings = settings
	alert.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alert.z_index = 150
	
	add_child(alert)
	
	await get_tree().process_frame
	var screen_size = get_viewport_rect().size
	alert.position = Vector2((screen_size.x - alert.size.x) / 2.0, 150)
	
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(alert):
		alert.queue_free()

func _show_history_modal():
	# Criar modal com fundo
	var modal_bg = ColorRect.new()
	modal_bg.color = Color(0, 0, 0, 0.85)
	modal_bg.size = get_viewport_rect().size
	modal_bg.z_index = 200
	add_child(modal_bg)
	
	# Container principal com glassmorphism
	var modal_panel = Panel.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	panel_style.set_corner_radius_all(30)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1, 0.7, 0.2, 0.5)
	panel_style.shadow_size = 20
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	modal_panel.add_theme_stylebox_override("panel", panel_style)
	modal_panel.custom_minimum_size = Vector2(920, 1650)
	modal_panel.position = Vector2(80, 135)
	modal_panel.z_index = 201
	add_child(modal_panel)
	
	# VBox container
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 20)
	vbox.offset_left = 20
	vbox.offset_top = 25
	vbox.offset_right = -20
	vbox.offset_bottom = -20
	modal_panel.add_child(vbox)
	
	# Título com ícone
	var title_container = HBoxContainer.new()
	title_container.alignment = BoxContainer.ALIGNMENT_CENTER
	title_container.add_theme_constant_override("separation", 15)
	vbox.add_child(title_container)
	
	var title_icon = Label.new()
	title_icon.text = "📜"
	title_icon.add_theme_font_size_override("font_size", 50)
	title_container.add_child(title_icon)
	
	var title = Label.new()
	title.text = LocalizationManager.translate("game_history_title", "HISTÓRICO")
	var title_settings = LabelSettings.new()
	title_settings.font_size = 55
	title_settings.font_color = Color(1, 0.7, 0.2, 1)
	title_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	title.label_settings = title_settings
	title_container.add_child(title)
	
	# Contador de cartas
	var counter = Label.new()
	var cards_played_text = LocalizationManager.translate("game_history_cards_played", "%d cartas jogadas")
	counter.text = cards_played_text % card_history.size()
	counter.add_theme_font_size_override("font_size", 28)
	counter.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(counter)
	
	# Separador
	var separator = HSeparator.new()
	separator.add_theme_constant_override("separation", 10)
	vbox.add_child(separator)
	
	# ScrollContainer
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 1350
	vbox.add_child(scroll)
	
	# Lista de cartas
	var card_list = VBoxContainer.new()
	card_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_list.add_theme_constant_override("separation", 18)
	scroll.add_child(card_list)
	
	# Adicionar cartas ao histórico (ordem reversa - mais recentes primeiro)
	if card_history.is_empty():
		var empty_container = VBoxContainer.new()
		empty_container.alignment = BoxContainer.ALIGNMENT_CENTER
		empty_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card_list.add_child(empty_container)
		
		var empty_icon = Label.new()
		empty_icon.text = ""
		empty_icon.add_theme_font_size_override("font_size", 80)
		empty_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_container.add_child(empty_icon)
		
		var empty_label = Label.new()
		empty_label.text = LocalizationManager.translate("game_history_empty", "Nenhuma carta vista ainda")
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 35)
		empty_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
		empty_container.add_child(empty_label)
	else:
		for i in range(card_history.size() - 1, -1, -1):
			var card = card_history[i]
			_add_history_card_item(card_list, card, i + 1)
	
	# Botão fechar estilizado
	var close_btn = Button.new()
	close_btn.text = LocalizationManager.translate("game_history_close", "FECHAR")
	close_btn.add_theme_font_size_override("font_size", 45)
	close_btn.custom_minimum_size = Vector2(350, 70)
	close_btn.flat = true
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.3, 0.15, 0.15, 0.8)
	close_style.set_corner_radius_all(15)
	close_style.border_width_left = 1
	close_style.border_width_top = 1
	close_style.border_width_right = 1
	close_style.border_width_bottom = 1
	close_style.border_color = Color(1, 0.4, 0.4, 0.5)
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_stylebox_override("hover", close_style)
	close_btn.add_theme_stylebox_override("pressed", close_style)
	
	var btn_container = HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_container.add_child(close_btn)
	vbox.add_child(btn_container)
	
	close_btn.pressed.connect(func():
		modal_bg.queue_free()
		modal_panel.queue_free()
	)
	
	# Animação de entrada
	modal_panel.modulate.a = 0.0
	modal_panel.scale = Vector2(0.9, 0.9)
	var tw = modal_panel.create_tween().set_parallel(true)
	tw.tween_property(modal_panel, "modulate:a", 1.0, 0.3)
	tw.tween_property(modal_panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _add_history_card_item(container: VBoxContainer, card: Dictionary, number: int):
	var item_panel = PanelContainer.new()
	var item_style = StyleBoxFlat.new()
	var base_color = _get_category_color(card.category)
	item_style.bg_color = base_color
	item_style.set_corner_radius_all(15)
	item_style.shadow_size = 8
	item_style.shadow_color = Color(0, 0, 0, 0.3)
	item_style.shadow_offset = Vector2(3, 3)
	item_panel.add_theme_stylebox_override("panel", item_style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	item_panel.add_child(margin)
	
	var item_vbox = VBoxContainer.new()
	item_vbox.add_theme_constant_override("separation", 8)
	margin.add_child(item_vbox)
	
	# Header com número, categoria e indicador de raridade
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 10)
	item_vbox.add_child(header_hbox)
	
	# Número da carta em círculo
	var number_label = Label.new()
	number_label.text = "#" + str(number)
	var number_settings = LabelSettings.new()
	number_settings.font_size = 26
	number_settings.font_color = Color(0, 0, 0, 0.7)
	number_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	number_label.label_settings = number_settings
	header_hbox.add_child(number_label)
	
	# Nome da categoria
	var category_label = Label.new()
	var display_name = card.category.replace("_raros", " RARA").capitalize()
	category_label.text = display_name
	var cat_settings = LabelSettings.new()
	cat_settings.font_size = 28
	cat_settings.font_color = Color(0, 0, 0, 0.85)
	cat_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	category_label.label_settings = cat_settings
	category_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(category_label)
	
	# Indicador de carta rara
	if card.get("is_rare", false):
		var rare_indicator = Label.new()
		rare_indicator.text = "RARA"
		var rare_settings = LabelSettings.new()
		rare_settings.font_size = 22
		rare_settings.font_color = Color(0.1, 0.1, 0.1, 0.9)
		rare_settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
		rare_indicator.label_settings = rare_settings
		header_hbox.add_child(rare_indicator)
	
	# Texto da carta (truncado se muito longo)
	var text = Label.new()
	var card_text = card.text
	# Remover marcadores [DICE], [COMPASS], etc
	card_text = card_text.replace("[DICE]", "[DADO]").replace("[COMPASS]", "[ROLETA]")
	if card_text.length() > 150:
		card_text = card_text.substr(0, 147) + "..."
	text.text = card_text
	var text_settings = LabelSettings.new()
	text_settings.font_size = 26
	text_settings.font_color = Color(0, 0, 0, 0.95)
	text.label_settings = text_settings
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	item_vbox.add_child(text)
	
	container.add_child(item_panel)
	
	# Animação de entrada
	item_panel.modulate.a = 0.0
	var delay = (card_history.size() - number) * 0.03
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(item_panel):
		var tween = item_panel.create_tween()
		tween.tween_property(item_panel, "modulate:a", 1.0, 0.25)

func _get_category_color(category: String) -> Color:
	match category:
		"classico": return Color(1, 1, 1, 1)
		"classico_raros": return Color(1, 0.95, 0.6, 1)
		"nonsense": return Color(1, 0.392, 0.624, 1)
		"nonsense_raros": return Color(1, 0.6, 0.76, 1)
		"weirdo": return Color(0.351, 0.946, 0.858, 1)
		"weirdo_raros": return Color(0.5, 1, 0.9, 1)
		"languages": return Color(0.989, 0.667, 0.411, 1)
		"languages_raros": return Color(1, 0.8, 0.55, 1)
		"pool": return Color(0.688, 0.214, 0.901, 1)
		"pool_raros": return Color(0.8, 0.4, 1, 1)
		"spicy": return Color(1, 0.13, 0.231, 1)
		"spicy_raros": return Color(1, 0.4, 0.45, 1)
	return Color.WHITE

func _exit_tree():
	# Desativar keep screen on ao sair
	DisplayServer.screen_set_keep_on(false)
	
	if tween:
		tween.kill()
		tween = null
	if card_shadow and is_instance_valid(card_shadow):
		card_shadow.queue_free()
		card_shadow = null
func _capture_photo():
	# Debug: verificar feeds disponíveis
	var feed_count = CameraServer.get_feed_count()
	print("📸 Câmeras disponíveis: ", feed_count)
	
	# Tentar usar câmera do dispositivo se disponível
	if feed_count > 0:
		print("✅ Abrindo câmera...")
		var capture_scene = load("res://Scenes/camera_capture.tscn")
		if capture_scene:
			var overlay = capture_scene.instantiate()
			overlay.photo_captured.connect(_on_device_photo_captured)
			overlay.capture_cancelled.connect(func():
				if is_instance_valid(overlay):
					overlay.queue_free()
			)
			add_child(overlay)
			return
	
	# Fallback: screenshot do viewport
	print("Usando screenshot (camera nao detectada no desktop)")
	_show_toast("📸 Foto tirada! (modo screenshot)")
	_capture_screenshot()

func _show_toast(msg: String):
	var lbl = Label.new()
	lbl.text = msg
	var ls = LabelSettings.new()
	ls.font_size = 36
	ls.font_color = Color(0.3, 0.9, 0.3, 1)
	ls.outline_size = 5
	ls.outline_color = Color.BLACK
	lbl.label_settings = ls
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.z_index = 300
	add_child(lbl)
	await get_tree().process_frame
	lbl.position = Vector2((get_viewport_rect().size.x - lbl.size.x) / 2, 200)
	var tw = create_tween()
	lbl.modulate.a = 0.0
	tw.tween_property(lbl, "modulate:a", 1.0, 0.3)
	await get_tree().create_timer(1.5).timeout
	tw = create_tween()
	tw.tween_property(lbl, "modulate:a", 0.0, 0.4)
	await tw.finished
	if is_instance_valid(lbl):
		lbl.queue_free()

func _capture_screenshot():
	# Capturar screenshot do viewport
	var img := get_viewport().get_texture().get_image()
	if img:
		var dir = DirAccess.open("user://")
		if dir and not dir.dir_exists("user://photos"):
			dir.make_dir("photos")
		var ts = Time.get_unix_time_from_system()
		var path = "user://photos/photo_%d.png" % ts
		var err = img.save_png(path)
		if err == OK:
			session_photos.append(path)
			await _show_photo_saved_toast("📸 Screenshot salva!")

func _on_device_photo_captured(path: String) -> void:
	if path != "":
		session_photos.append(path)
		var message := "📸 Foto salva na galeria!"
		if OS.has_feature("android"):
			message = "📸 Foto salva na galeria do dispositivo!"
		await _show_photo_saved_toast(message)

func _show_photo_saved_toast(message: String) -> void:
	var saved = Label.new()
	saved.text = message
	var settings = LabelSettings.new()
	settings.font_size = 40
	settings.font_color = Color("a3ffab")
	settings.outline_size = 4
	settings.outline_color = Color.BLACK
	saved.label_settings = settings
	saved.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	saved.z_index = 160
	add_child(saved)
	await get_tree().process_frame
	var screen = get_viewport_rect().size
	saved.position = Vector2((screen.x - saved.size.x) / 2.0, 140)
	
	var tw = create_tween()
	saved.modulate.a = 0.0
	tw.tween_property(saved, "modulate:a", 1.0, 0.3)
	await get_tree().create_timer(1.2).timeout
	tw = create_tween()
	tw.tween_property(saved, "modulate:a", 0.0, 0.5)
	await tw.finished
	if is_instance_valid(saved):
		saved.queue_free()

func _show_wrapped_report():
	# Debug: verificar fotos salvas
	print("📸 Total de fotos na sessão: ", session_photos.size())
	for photo_path in session_photos:
		print("  - ", photo_path)
	
	# Carregar cena de wrapped e passar dados
	var scene = load("res://Scenes/wrapped.tscn")
	if not scene:
		print("❌ Erro ao carregar wrapped.tscn")
		return
	var wrapped = scene.instantiate()
	wrapped.set("card_history", card_history)
	wrapped.set("session_photos", session_photos)
	wrapped.set("session_start_time", session_start_time)
	
	print("✅ Passando ", session_photos.size(), " fotos para o wrapped")
	
	var current = get_tree().current_scene
	get_tree().root.add_child(wrapped)
	get_tree().set_current_scene(wrapped)
	if current and is_instance_valid(current):
		current.queue_free()
	
	# Verificar conquista "Maratonista" (1 hora de jogo)
	_check_marathon_achievement()

func _check_rare_achievements():
	if not AchievementsManager:
		return
	
	# Verificar "Primeira Rara"
	if AchievementsManager.unlock_achievement("first_rare"):
		_show_achievement_notification("first_rare")
	
	# Verificar "Colecionador" (contar cartas raras no histórico)
	var rare_count = 0
	for card in card_history:
		if card.get("is_rare", false):
			rare_count += 1
	
	if rare_count >= 10:
		if AchievementsManager.unlock_achievement("collector"):
			_show_achievement_notification("collector")

func _check_pack_completion(category: String):
	if not AchievementsManager:
		return
	
	# Remover sufixo "_raros" se existir para pegar o pack base
	var base_category = category.replace("_raros", "")
	
	# Verificar se o pack foi completamente zerado
	if displayed_texts.has(category):
		if displayed_texts[category].size() >= card_data[category].size():
			# Pack zerado! Verificar conquista específica
			var achievement_id = "pack_" + base_category + "_completed"
			if AchievementsManager.unlock_achievement(achievement_id):
				_show_achievement_notification(achievement_id)

func _check_all_cards_completion():
	if not AchievementsManager:
		return
	
	# Verificar se todas as cartas de todos os packs selecionados foram jogadas
	var all_completed = true
	var available_categories = pack_state.keys().filter(func(p): return pack_state[p])
	
	for category in available_categories:
		if card_data.has(category):
			if not displayed_texts.has(category):
				displayed_texts[category] = []
			if displayed_texts[category].size() < card_data[category].size():
				all_completed = false
				break
		
		# Verificar também cartas raras
		var rare_category = category + "_raros"
		if card_data.has(rare_category):
			if not displayed_texts.has(rare_category):
				displayed_texts[rare_category] = []
			if displayed_texts[rare_category].size() < card_data[rare_category].size():
				all_completed = false
				break
	
	if all_completed:
		if AchievementsManager.unlock_achievement("all_cards_completed"):
			_show_achievement_notification("all_cards_completed")

func _check_social_achievement():
	if not AchievementsManager:
		return
	
	var selected_packs_count = 0
	for pack_name in pack_state.keys():
		if pack_state[pack_name]:
			selected_packs_count += 1
	
	if selected_packs_count >= 5:
		if AchievementsManager.unlock_achievement("social"):
			_show_achievement_notification("social")

func _check_marathon_achievement():
	if not AchievementsManager:
		return
	
	var session_duration_ms = Time.get_ticks_msec() - session_start_time
	var session_duration_hours = session_duration_ms / (1000.0 * 60.0 * 60.0)
	
	if session_duration_hours >= 1.0:
		if AchievementsManager.unlock_achievement("marathon"):
			_show_achievement_notification("marathon")

func _check_perfectionist_achievement():
	if not AchievementsManager:
		return
	
	# Verificar se todos os packs foram zerados em sessões separadas
	# Isso será verificado quando cada pack individual for zerado
	# Se todos os packs individuais estiverem desbloqueados, desbloquear "Perfeccionista"
	var all_packs_unlocked = true
	var pack_achievements = [
		"pack_classico_completed",
		"pack_nonsense_completed",
		"pack_weirdo_completed",
		"pack_languages_completed",
		"pack_pool_completed",
		"pack_spicy_completed"
	]
	
	for achievement_id in pack_achievements:
		if not AchievementsManager.is_achievement_unlocked(achievement_id):
			all_packs_unlocked = false
			break
	
	if all_packs_unlocked:
		if AchievementsManager.unlock_achievement("perfectionist"):
			_show_achievement_notification("perfectionist")

func _show_achievement_notification(achievement_id: String):
	if not AchievementsManager:
		return
	
	var achievement_info = AchievementsManager.get_achievement_info(achievement_id)
	if achievement_info.is_empty():
		return
	
	# Criar notificação visual
	var notification = Label.new()
	notification.text = achievement_info.get("icon", "🏆") + " " + achievement_info.get("name", "Conquista!")
	
	var settings = LabelSettings.new()
	settings.font_size = 50
	settings.font_color = Color(1, 0.84, 0, 1)  # Dourado
	settings.outline_size = 6
	settings.outline_color = Color(0, 0, 0, 1)
	settings.font = load("res://Fonts/Oswald-VariableFont_wght.ttf")
	notification.label_settings = settings
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification.z_index = 2000
	add_child(notification)
	
	await get_tree().process_frame
	
	if not is_instance_valid(notification):
		return
	
	var screen = get_viewport_rect().size
	notification.position = Vector2((screen.x - notification.size.x) / 2.0, 200)
	
	notification.modulate.a = 0.0
	notification.scale = Vector2(0.5, 0.5)
	
	var tween = notification.create_tween().set_parallel(true)
	tween.tween_property(notification, "modulate:a", 1.0, 0.5)
	tween.tween_property(notification, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)
	
	# Vibrar
	UIManager.safe_vibrate(200)
	
	# Partículas de confete
	ParticlesManager.create_confetti(self, notification.position + Vector2(notification.size.x / 2, notification.size.y), Color(1, 0.84, 0, 1))
	
	await get_tree().create_timer(3.0).timeout
	
	if is_instance_valid(notification):
		tween = notification.create_tween()
		tween.tween_property(notification, "modulate:a", 0.0, 0.5)
		await tween.finished
		if is_instance_valid(notification):
			notification.queue_free()

func _load_saved_filters():
	# Carregar filtros salvos das configurações
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		var saved_filters = config.get_value("settings", "selected_filters", [])
		if saved_filters is Array:
			# Converter para Array[String]
			active_filters.clear()
			for filter in saved_filters:
				if filter is String:
					active_filters.append(filter)
