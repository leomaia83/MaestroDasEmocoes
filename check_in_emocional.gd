extends Control

func _ready():
	# Conectamos os botões via código para facilitar
	for botao in $HBoxContainer.get_children():
		botao.pressed.connect(_ao_selecionar_humor.bind(botao.name))

func _ao_selecionar_humor(nome_humor):
	Global.humor_do_dia = nome_humor
	print("A criança está se sentindo: ", nome_humor)
	# Aqui você chamaria a próxima tela (a das causas)
	Global.mudar_fase("res://causas_humor.tscn")
