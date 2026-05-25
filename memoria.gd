extends Control

@onready var grid_cartas = $GridContainer

# Arraste a imagem do verso (a carta com o coração) para cá no Inspetor
@export var imagem_verso: Texture2D

# Array de Imagens que aceita o arrastar e soltar perfeitamente no Inspetor
@export var lista_imagens_frente: Array[Texture2D] = []

var primeira_carta: Button = null
var segunda_carta: Button = null
var pares_encontrados: int = 0
const TOTAL_PARES : int = 6

func _ready():
	print("Jogo da Memória dos Sentimentos Iniciado.")
	
	# 1. Cria uma lista temporária com todas as cartas
	var lista_cartas: Array = []
	for carta in grid_cartas.get_children():
		if carta is Button:
			lista_cartas.append(carta)
			
			# Configuração inicial (bota o verso nelas e conecta o clique)
			carta.icon = imagem_verso
			carta.expand_icon = true
			carta.pressed.connect(_on_carta_pressed.bind(carta))
	
	# 2. A MÁGICA: Mistura a ordem dos botões na lista de forma totalmente aleatória!
	lista_cartas.shuffle()
	
	# 3. Atualiza a árvore do Godot para seguir a nova ordem misturada
	for i in range(lista_cartas.size()):
		grid_cartas.move_child(lista_cartas[i], i)

func _on_carta_pressed(carta: Button):
	# Evita que o jogador clique na mesma carta duas vezes ou clique enquanto o jogo confere
	if carta == primeira_carta or carta == segunda_carta:
		return
		
	# Descobre o índice da imagem pelo nome do nó (ex: "Carta_2_A" extrai o "2")
	var partes_nome = carta.name.split("_")
	if partes_nome.size() < 2:
		print("Erro: O nome do nó ", carta.name, " não está no formato 'Carta_0_A'")
		return
		
	var indice_imagem = int(partes_nome[1])
	
	# "Vira" a carta mostrando a imagem correspondente da nossa Array
	if indice_imagem >= 0 and indice_imagem < lista_imagens_frente.size():
		carta.icon = lista_imagens_frente[indice_imagem]
	
	if primeira_carta == null:
		primeira_carta = carta
	elif segunda_carta == null:
		segunda_carta = carta
		_verificar_par()

func _verificar_par():
	# Compara os índices numéricos das cartas (ex: "2" da Carta_2_A com "2" da Carta_2_B)
	var id1 = primeira_carta.name.split("_")[1]
	var id2 = segunda_carta.name.split("_")[1]
	
	if id1 == id2:
		# Acertou o par! Desativa as duas para não serem clicadas de novo
		primeira_carta.disabled = true
		segunda_carta.disabled = true
		
		primeira_carta = null
		segunda_carta = null
		
		pares_encontrados += 1
		print("Par encontrado! Total: ", pares_encontrados)
		
		if pares_encontrados >= TOTAL_PARES:
			await get_tree().create_timer(1.5).timeout
			Global.mudar_fase(Global.TELA_FEEDBACK)
	else:
		# Errou o par! Bloqueia cliques temporariamente para dar tempo de ver o erro
		get_viewport().set_input_as_handled() 
		
		# Espera 1 segundo para a criança memorizar e depois desvira
		await get_tree().create_timer(1.0).timeout
		
		if primeira_carta != null and segunda_carta != null:
			primeira_carta.icon = imagem_verso
			segunda_carta.icon = imagem_verso
			
		primeira_carta = null
		segunda_carta = null
