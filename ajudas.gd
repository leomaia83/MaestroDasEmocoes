extends Control

# Certifique-se de ter botões chamados OpcaoAbraco, OpcaoDesenho, etc.
@onready var container_opcoes = $VBoxContainer 

func _ready():
	print("Missão de Empatia iniciada. Escolha o que pode ajudar!")
	for botao in container_opcoes.get_children():
		botao.pressed.connect(_on_opcao_escolhida.bind(botao.name))

func _on_opcao_escolhida(nome_opcao):
	print("A criança escolheu a solução: ", nome_opcao)
	# Feedback visual de sucesso direto, validando a boa escolha
	for b in container_opcoes.get_children():
		b.disabled = true
	
	await get_tree().create_timer(1.5).timeout
	Global.mudar_fase(Global.TELA_FEEDBACK)
