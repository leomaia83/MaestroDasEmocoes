extends Control

@onready var label_missao = $LabelMissao
@onready var termometro_barra = %TextureProgressBar # Mudou para % (Acesso Único)
@onready var slider_controle = %VSlider             # Mudou para % (Acesso Único)
@onready var botao_confirmar = $ButtonConfirmar

# Lista de conquistas para gerar orgulho (o jogo pode escolher uma aleatória!)
var situacoes_orgulho: Array[String] = [
	"Você conseguiu amarrar o sapato sozinho!",
	"Você ajudou um amigo que estava triste na escola!",
	"Você terminou toda a sua tarefa de casa!",
	"Você guardou todos os seus brinquedos no lugar certo!"
]

func _ready():
	print("Minijogo do Termômetro do Orgulho Iniciado.")
	
	# 1. Escolhe uma situação aleatória para mostrar na tela
	situacoes_orgulho.shuffle()
	label_missao.text = "O Maestro quer saber:\nO quão orgulhoso você se sente quando...\n\n\"" + situacoes_orgulho[0] + "\""
	
	# 2. Configura os valores do Slider e da Barra (de 0 a 100)
	slider_controle.min_value = 0
	slider_controle.max_value = 100
	slider_controle.value = 10 # Começa um pouquinho cheio embaixo
	
	termometro_barra.min_value = 0
	termometro_barra.max_value = 100
	termometro_barra.value = slider_controle.value
	
	# 3. Conecta os sinais dos botões e do slider
	slider_controle.value_changed.connect(_on_slider_value_changed)
	botao_confirmar.pressed.connect(_on_botao_confirmar_pressionado)

func _on_slider_value_changed(novo_valor: float):
	# Faz a barra do termômetro seguir exatamente a posição do Slider em tempo real!
	termometro_barra.value = novo_valor

func _on_botao_confirmar_pressionado():
	# Valida se a criança interagiu com o termômetro
	if slider_controle.value <= 15:
		# Pequeno feedback caso ela clique sem arrastar
		label_missao.text = "Arraste o termômetro para cima para medir o seu orgulho!"
		return
		
	print("Nível de orgulho registrado: ", slider_controle.value)
	label_missao.text = "Isso aí! É muito importante ter orgulho das suas conquistas! ✨"
	
	# Trava o controle para evitar cliques duplos
	botao_confirmar.disabled = true
	slider_controle.editable = false
	
	# Espera 2 segundos para dar tempo de ler e vai para a tela de feedback final!
	await get_tree().create_timer(2.5).timeout
	Global.mudar_fase(Global.TELA_FEEDBACK)
