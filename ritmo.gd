extends Control

# Assets pré-carregados
const TEXTURA_AMARELA = preload("res://assets quest 3/notaAmarela.png")
const TEXTURA_VERDE = preload("res://assets quest 3/notaVerde.png")
const TEXTURA_ROXA = preload("res://assets quest 3/notaRoxa.png")
const TEXTURA_AZUL = preload("res://assets quest 3/notaAzul.png")
const TEXTURA_CINZA = preload("res://assets quest 3/notaCinza.png") # Nota cinza/apagada

# Banco de texturas coloridas para mapeamento fácil (0 a 3)
@onready var banco_texturas = [TEXTURA_AMARELA, TEXTURA_AZUL, TEXTURA_ROXA, TEXTURA_VERDE]

# Referências diretas e únicas aos nós da sua árvore
@onready var visual_notas_topo = $MarginContainer/VBoxContainer/PanelNotasSequencia/HBoxContainer
@onready var container_botoes = $MarginContainer/VBoxContainer/HBoxContainer
@onready var label_sequencia = $MarginContainer/VBoxContainer/HBoxContainer2/LabelSequencia
@onready var botao_acao = $MarginContainer/VBoxContainer/ButtonTocarSequencia
@onready var timer = $Timer

# Lógica do Jogo
var sequencia_maestro : Array = []
var sequencia_jogador : Array = []
var lista_botoes_clique : Array = []
var lista_icones_topo : Array = []

var indice_exibicao : int = 0
var jogando_sequencia : bool = false

const TOTAL_RODADAS = 3
var rodada_atual : int = 1

# Cores para feedback visual nos botões inferiores
var cor_normal = Color(0.8, 0.8, 0.8)
var cor_brilhante = Color(1.5, 1.5, 1.5)

func _ready():
	# Coleta as referências dos nós filhos nos contêineres
	lista_botoes_clique = container_botoes.get_children()
	lista_icones_topo = visual_notas_topo.get_children()
	
	# Configura os botões de clique inferiores
	for i in range(lista_botoes_clique.size()):
		var b = lista_botoes_clique[i]
		b.modulate = cor_normal
		b.pressed.connect(_on_botao_nota_pressionado.bind(i))
		
	# Conecta os sinais globais
	timer.timeout.connect(_proxima_nota_da_sequencia)
	botao_acao.pressed.connect(iniciar_nova_rodada)
	
	atualizar_interface()

func atualizar_interface():
	label_sequencia.text = "Sequência %d de %d" % [rodada_atual, TOTAL_RODADAS]
	botao_acao.text = "Tocar sequência"
	botao_acao.disabled = false

func iniciar_nova_rodada():
	if jogando_sequencia: return
	
	jogando_sequencia = true
	botao_acao.disabled = true
	botao_acao.text = "Ouvindo..."
	sequencia_jogador.clear()
	
	# Oculta as notas do topo para irem aparecendo de forma centralizada no ritmo
	for icone in lista_icones_topo:
		icone.texture = TEXTURA_CINZA
		icone.visible = false 
	
	# Sorteia uma nova nota (0 a 3)
	sequencia_maestro.append(randi() % lista_botoes_clique.size())
	
	indice_exibicao = 0
	timer.wait_time = 0.8
	timer.start()

func _proxima_nota_da_sequencia():
	for b in lista_botoes_clique:
		b.modulate = cor_normal
		
	if indice_exibicao < sequencia_maestro.size():
		var index_nota = sequencia_maestro[indice_exibicao]
		
		# 1. Pisca o botão inferior
		lista_botoes_clique[index_nota].modulate = cor_brilhante
		
		# 2. Mostra e colore a nota correspondente no topo
		if indice_exibicao < lista_icones_topo.size():
			var icone_topo = lista_icones_topo[indice_exibicao]
			icone_topo.texture = banco_texturas[index_nota]
			icone_topo.visible = true
		
		# 3. 🔊 TOCAR SOM CORRIGIDO (Maestro)
		var nomes_dos_sons = ["notaF", "notaG", "notaA", "notaC"]
		var som_node_name = nomes_dos_sons[index_nota]
		
		if has_node(som_node_name):
			get_node(som_node_name).play()
		else:
			print("Erro: Crie um AudioStreamPlayer com o nome exato: ", som_node_name)
		
		indice_exibicao += 1
	else:
		timer.stop()
		jogando_sequencia = false
		botao_acao.text = "Sua vez!"

func _on_botao_nota_pressionado(index_clicado):
	if jogando_sequencia:
		return
		
	var botao = lista_botoes_clique[index_clicado]
	botao.modulate = cor_brilhante
	
	# 🔊 TOCAR SOM CORRIGIDO (Clique da Criança)
	var nomes_dos_sons = ["notaF", "notaG", "notaA", "notaC"]
	var som_node_name = nomes_dos_sons[index_clicado]
	
	if has_node(som_node_name):
		get_node(som_node_name).play()
	else:
		print("Erro: Crie um AudioStreamPlayer com o nome exato: ", som_node_name)
	
	await get_tree().create_timer(0.2).timeout
	botao.modulate = cor_normal
	
	sequencia_jogador.append(index_clicado)
	
	var passo_atual = sequencia_jogador.size() - 1
	if sequencia_jogador[passo_atual] != sequencia_maestro[passo_atual]:
		_rodada_errada()
		return
		
	if sequencia_jogador.size() == sequencia_maestro.size():
		_rodada_vencida()

func _rodada_errada():
	sequencia_jogador.clear()
	botao_acao.disabled = false
	botao_acao.text = "Tentar de novo"
	
	# Reseta as notas visuais do topo se o jogador errar, escondendo-as novamente
	for icone in lista_icones_topo:
		icone.texture = TEXTURA_CINZA
		icone.visible = false

func _rodada_vencida():
	if rodada_atual < TOTAL_RODADAS:
		rodada_atual += 1
		atualizar_interface()
		botao_acao.text = "Próximo ritmo"
	else:
		botao_acao.text = "Parabéns!"
		await get_tree().create_timer(1.0).timeout
		# 🎯 FIX: Agora usando a constante em caixa alta definida no Global.gd
		Global.mudar_fase(Global.TELA_FEEDBACK)
