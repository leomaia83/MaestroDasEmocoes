extends Control

# Referências dos contêineres na árvore
@onready var container_apoiadores = $ContainerApoiadores
@onready var container_situacoes = $ContainerSituacoes
@onready var label_progresso = $LabelProgresso
@onready var botao_avancar = $ButtonAvancar

# Variáveis de controle do estado do jogo
var situacao_selecionada : String = ""
var apoios_realizados : int = 0
const TOTAL_APOIOS_NECESSARIOS : int = 3 # Exige 3 combinações para liberar

# Cores de feedback visual
var cor_normal = Color(1, 1, 1)
var cor_selecionado = Color(1.5, 1.5, 0.8) # Deixa o botão destacado

func _ready():
	# Desativa o botão de avançar até que a criança faça as escolhas
	botao_avancar.disabled = true
	botao_avancar.text = "Escolha as ajudas..."
	atualizar_interface()
	
	# Configura os botões de Situações (filhos diretos do GridContainer)
	for botao in container_situacoes.get_children():
		if botao is Button:
			botao.pressed.connect(_on_situacao_pressionada.bind(botao))
			
	# Configura os botões de Apoiadores (parte de cima)
	for botao in container_apoiadores.get_children():
		if botao is Button:
			botao.pressed.connect(_on_apoiador_pressionado.bind(botao))
			
	# Conecta o botão final de avanço
	botao_avancar.pressed.connect(_on_botao_avancar_pressionado)

func atualizar_interface():
	label_progresso.text = "%d apoios de %d" % [apoios_realizados, TOTAL_APOIOS_NECESSARIOS]
	if apoios_realizados >= TOTAL_APOIOS_NECESSARIOS:
		botao_avancar.disabled = false
		botao_avancar.text = "Escolher ajuda"

func _on_situacao_pressionada(botao_clicado: Button):
	# Limpa seleção visual anterior das situações
	for b in container_situacoes.get_children():
		if b is Button: b.modulate = cor_normal
		
	# Seleciona a nova situação
	situacao_selecionada = botao_clicado.name
	botao_clicado.modulate = cor_selecionado
	print("Criança selecionou a situação: ", situacao_selecionada)

func _on_apoiador_pressionado(botao_clicado: Button):
	if situacao_selecionada == "":
		print("Nenhuma situação selecionada ainda! Escolha um sentimento abaixo primeiro.")
		return 
		
	print("Criança associou ", situacao_selecionada, " ao apoiador: ", botao_clicado.name)
	
	# Feedback visual rápido de sucesso na combinação
	botao_clicado.modulate = cor_selecionado
	await get_tree().create_timer(0.4).timeout
	botao_clicado.modulate = cor_normal
	
	# Reseta a situação atual e desativa o botão usado
	for b in container_situacoes.get_children():
		if b is Button and b.name == situacao_selecionada:
			b.disabled = true
			b.modulate = cor_normal
			
	situacao_selecionada = ""
	apoios_realizados += 1
	atualizar_interface()

func _on_botao_avancar_pressionado():
	print("Missão de Empatia concluída com sucesso!")
	Global.mudar_fase(Global.TELA_FEEDBACK)
