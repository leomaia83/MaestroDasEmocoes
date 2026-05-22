extends Control

@onready var grid_cartas = $GridContainer

var primeira_carta : Button = null
var segunda_carta : Button = null
var pares_encontrados : int = 0
const TOTAL_PARES : int = 4

func _ready():
	print("Jogo da Memória dos Sentimentos Iniciado.")
	# Atribui o clique para todas as cartas no GridContainer
	for carta in grid_cartas.get_children():
		carta.pressed.connect(_on_carta_pressed.bind(carta))

func _on_carta_pressed(carta: Button):
	if primeira_carta == null:
		primeira_carta = carta
		carta.disabled = true # Revela a primeira
	elif segunda_carta == null:
		segunda_carta = carta
		carta.disabled = true # Revela a segunda
		_verificar_par()

func _verificar_par():
	# Usamos o prefixo do nome do botão na árvore para checar o par (Ex: "Feliz_1" e "Feliz_2")
	var id1 = primeira_carta.name.split("_")[0]
	var id2 = segunda_carta.name.split("_")[0]
	
	if id1 == id2:
		pares_encontrados += 1
		primeira_carta.modulate = Color(0,1,0)
		segunda_carta.modulate = Color(0,1,0)
		primeira_carta = null
		segunda_carta = null
		
		if pares_encontrados >= TOTAL_PARES:
			await get_tree().create_timer(1.0).timeout
			Global.mudar_fase(Global.TELA_FEEDBACK)
	else:
		# Se errou, vira as cartas de volta escondendo-as
		await get_tree().create_timer(1.0).timeout
		primeira_carta.disabled = false
		segunda_carta.disabled = false
		primeira_carta = null
		segunda_carta = null
