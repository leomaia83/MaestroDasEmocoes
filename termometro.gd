extends Control

@onready var container = $ContainerNiveis

func _ready():
	print("Minijogo do Termômetro iniciado. Escolha a intensidade!")
	for botao in container.get_children():
		botao.pressed.connect(_on_intensidade_escolhida.bind(botao.name))

func _on_intensidade_escolhida(nivel):
	print("A intensidade da emoção é: ", nivel)
	# Desativa os botões para evitar cliques duplos
	for b in container.get_children():
		b.disabled = true
		
	await get_tree().create_timer(1.2).timeout
	Global.mudar_fase(Global.TELA_FEEDBACK)
