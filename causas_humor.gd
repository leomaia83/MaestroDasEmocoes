extends Control

func _ready():
	# Conecta todos os botões de motivos (Casa, Escola, Amigos...) automaticamente
	# Certifique-se de que eles estão dentro de um Container chamado GridContainer ou HBoxContainer
	for botao in $GridContainer.get_children():
		botao.pressed.connect(_ao_selecionar_motivo.bind(botao.name))

func _ao_selecionar_motivo(nome_motivo):
	# Salva o motivo escolhido na variável global
	Global.motivo_do_humor = nome_motivo
	print("O motivo do humor foi: ", nome_motivo)
	
	# Aciona a árvore de decisão inteligente que mapeamos!
	Global.definir_proximo_minijogo()
