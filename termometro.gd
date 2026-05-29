extends Control

@onready var label_missao = $LabelMissao
@onready var termometro_barra = %TextureProgressBar
@onready var slider_controle = %VSlider
@onready var botao_confirmar = $ButtonConfirmar

# Lista de conquistas para gerar orgulho
var situacoes_orgulho: Array[String] = [
	"Você conseguiu amarrar o sapato sozinho!",
	"Você ajudou um amigo que estava triste na escola!",
	"Você terminou toda a sua tarefa de casa!",
	"Você guardou todos os seus brinquedos no lugar certo!"
]

# Velocidade de subida/descida da barra
const VELOCIDADE_TERMOMETRO = 60.0

# Variável de controle para o arraste customizado por hardware
var arrastando: bool = false

func _ready():
	print("Minijogo do Termômetro do Orgulho - Sem Timers Ativo.")
	
	situacoes_orgulho.shuffle()
	label_missao.text = "O Maestro quer saber:\nO quão orgulhoso você se sente quando...\n\n\"" + situacoes_orgulho[0] + "\""
	
	slider_controle.min_value = 0
	slider_controle.max_value = 100
	slider_controle.value = 15
	
	termometro_barra.min_value = 0
	termometro_barra.max_value = 100
	termometro_barra.value = slider_controle.value
	
	# Desativa focos automáticos para o cursor se mover livremente
	slider_controle.focus_mode = Control.FOCUS_NONE
	if botao_confirmar:
		botao_confirmar.focus_mode = Control.FOCUS_NONE
		botao_confirmar.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		if botao_confirmar.pressed.is_connected(_on_botao_confirmar_pressionado):
			botao_confirmar.pressed.disconnect(_on_botao_confirmar_pressionado)
		botao_confirmar.pressed.connect(_on_botao_confirmar_pressionado)

	# Escuta diretamente o hardware do ESP32
	if has_node("/root/ControleSerial"):
		var controle = get_node("/root/ControleSerial")
		
		if controle.botao_hardware_pressionado.is_connected(_on_hardware_pressionado):
			controle.botao_hardware_pressionado.disconnect(_on_hardware_pressionado)
		if controle.botao_hardware_solto.is_connected(_on_hardware_solto):
			controle.botao_hardware_solto.disconnect(_on_hardware_solto)
			
		controle.botao_hardware_pressionado.connect(_on_hardware_pressionado)
		controle.botao_hardware_solto.connect(_on_hardware_solto)

func _process(delta):
	if botao_confirmar.disabled:
		return
		
	# Só move a barra se o usuário estiver ativamente segurando o botão no Slider
	if arrastando and has_node("/root/ControleSerial"):
		var controle = get_node("/root/ControleSerial")
		var entrada_y = controle.eixo_y
		
		if abs(entrada_y) > 0.15:
			var mudanca = -entrada_y * VELOCIDADE_TERMOMETRO * delta
			slider_controle.value = clamp(slider_controle.value + mudanca, 0, 100)
			termometro_barra.value = slider_controle.value

# --- MONITORAMENTO DO HARDWARE EM TEMPO REAL ---

func _on_hardware_pressionado():
	if _cursor_esta_no_slider():
		arrastando = true
		print("-> Arraste Iniciado.")

func _on_hardware_solto():
	if arrastando:
		arrastando = false
		print("-> Arraste parado. Valor fixado em: ", slider_controle.value)

# --- DETECTORES DE POSIÇÃO DO CURSOR ---

func _cursor_esta_no_slider() -> bool:
	if not slider_controle or not slider_controle.visible:
		return false
	var pos = get_viewport().get_mouse_position()
	if has_node("/root/CursorVirtual") and "posicao_cursor" in get_node("/root/CursorVirtual"):
		pos = get_node("/root/CursorVirtual").posicao_cursor
	return slider_controle.get_global_rect().has_point(pos)

# --- VALIDAÇÃO DIRETA ---

func _on_botao_confirmar_pressionado():
	print("-> Botão Confirmar clicado fisicamente.")
	
	# Valida se a criança interagiu com a barra
	if slider_controle.value <= 15:
		label_missao.text = "Segure o botão vermelho sobre o termômetro e use o analógico para subir!"
		return
		
	print("-> CONFIRMAÇÃO MANUAL RECEBIDA! Avançando de fase...")
	
	# Desabilita o botão para evitar cliques múltiplos idênticos
	botao_confirmar.disabled = true
	arrastando = false
	
	# Limpa as pontes de sinal do hardware antes de mudar de cena
	if has_node("/root/ControleSerial"):
		var controle = get_node("/root/ControleSerial")
		if controle.botao_hardware_pressionado.is_connected(_on_hardware_pressionado):
			controle.botao_hardware_pressionado.disconnect(_on_hardware_pressionado)
		if controle.botao_hardware_solto.is_connected(_on_hardware_solto):
			controle.botao_hardware_solto.disconnect(_on_hardware_solto)
	
	# Troca de cena IMEDIATAMENTE sem esperar nenhum segundo
	Global.mudar_fase(Global.TELA_FEEDBACK)
