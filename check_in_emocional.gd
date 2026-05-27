extends Control

func _ready():
	# Lista com os nomes exatos de todos os botões soltos na cena
	var botoes = ["Feliz", "Triste", "Bravo", "Assustado", "Cansado", "Orgulhoso"]
	
	for nome_botao in botoes:
		# Busca o botão diretamente como filho do nó principal (raiz)
		if has_node(nome_botao):
			var botao = get_node(nome_botao)
			
			# Garante que o Action Mode do botão reaja no clique imediato (Button Press)
			botao.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
			
			# Conecta o clique à função que gerencia a escolha da criança
			botao.pressed.connect(_ao_selecionar_humor.bind(nome_botao))

func _ao_selecionar_humor(nome_humor):
	# Guarda no Global se é Bravo, Feliz, Triste, etc.
	Global.humor_do_dia = nome_humor
	print("A criança está se sentindo: ", nome_humor)
	
	# Avança para a tela de causas (onde ela escolhe Casa, Escola, etc.)
	Global.mudar_fase(Global.TELA_CAUSAS)
