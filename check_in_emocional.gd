extends Control

func _ready():
	# Conecta todos os botões filhos do HBoxContainer automaticamente
	for botao in $HBoxContainer.get_children():
		botao.pressed.connect(_ao_selecionar_humor.bind(botao.name))

func _ao_selecionar_humor(nome_humor):
	# Guarda no Global se é Bravo, Feliz, Triste, etc.
	Global.humor_do_dia = nome_humor
	print("A criança está se sentindo: ", nome_humor)
	
	# Avança para a tela de causas (onde ela escolhe Casa, Escola, etc.)
	Global.mudar_fase(Global.TELA_CAUSAS)
