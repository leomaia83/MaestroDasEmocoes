extends Control

func _ready():
	# Conecta todos os botões da grade
	for botao in $VBoxContainer/GridContainer.get_children():
		botao.pressed.connect(_ao_clicar_na_causa.bind(botao.name))

func _ao_clicar_na_causa(nome_causa):
	Global.motivo_do_humor = nome_causa
	print("Motivo registrado: ", nome_causa)
	
	# Sequência lógica: Se a criança estiver com Raiva/Triste, 
	# o jogo a leva para o "Botão de Calma". 
	# Se estiver Bem, pode ir direto para o "Puzzle/DiverTIX".
	
	if Global.humor_do_dia == "Raiva" or Global.humor_do_dia == "Ansioso":
		Global.mudar_fase("res://botao_calma.tscn")
	else:
		Global.mudar_fase("res://diver_tix.tscn")
