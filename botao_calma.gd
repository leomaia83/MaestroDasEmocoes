extends Control

# Referências corrigidas e dinâmicas
@onready var label_titulo = $MarginContainer/VBoxContainer/LabelTitulo
@onready var label_subtitulo = $MarginContainer/VBoxContainer/LabelSubtitulo
@onready var visual_central = $MarginContainer/VBoxContainer/CentroAnimacao/VisualCentral
@onready var botao_ver_de_novo = $ButtonVerDeNovo

# Estados do exercício de respiração
enum Estado { PARADO, INSPIRAR, SEGURAR, SOLTAR, CONCLUIDO }
var estado_atual = Estado.PARADO
var tempo_estado : float = 0.0

# Tempos do ciclo de respiração
const TEMPO_INSPIRAR = 4.0
const TEMPO_SEGURAR = 2.0
const TEMPO_SOLTAR = 4.0

func _ready():
	print("Minijogo Botão Calma Iniciado - Nuvem Interativa Blindada.")
	
	label_titulo.text = "Respire com o Maestro"
	label_subtitulo.text = "Leve a seta até a nuvem e segure o botão vermelho!"
	
	if visual_central:
		visual_central.pivot_offset = visual_central.size / 2
		visual_central.scale = Vector2(1.0, 1.0)
		
		# Mantém a compatibilidade com cliques normais do mouse de testes
		visual_central.button_down.connect(_on_nuvem_pressionada)
		visual_central.button_up.connect(_on_nuvem_solta)

	# 🔥 CONEXÃO DIRETA COM O HARDWARE (Anti-trava do notebook)
	# Procura o gerenciador do controle serial na raiz do jogo
	if has_node("/root/ControleSerial"):
		var controle = get_node("/root/ControleSerial")
		
		# Desconecta para evitar conexões duplicadas acidentais
		if controle.botao_hardware_pressionado.is_connected(_on_hardware_pressionado):
			controle.botao_hardware_pressionado.disconnect(_on_hardware_pressionado)
		if controle.botao_hardware_solto.is_connected(_on_hardware_solto):
			controle.botao_hardware_solto.disconnect(_on_hardware_solto)
			
		# Conecta os sinais brutos de apertar e soltar vindos do ESP32!
		controle.botao_hardware_pressionado.connect(_on_hardware_pressionado)
		controle.botao_hardware_solto.connect(_on_hardware_solto)

func _process(delta):
	if estado_atual == Estado.PARADO or estado_atual == Estado.CONCLUIDO:
		return
		
	tempo_estado += delta
	
	match estado_atual:
		Estado.INSPIRAR:
			label_titulo.text = "Inspirar..."
			var tempo_restante = ceil(TEMPO_INSPIRAR - tempo_estado)
			label_subtitulo.text = str(tempo_restante) + " segundos"
			
			var progresso = tempo_estado / TEMPO_INSPIRAR
			var escala = lerp(1.0, 1.3, clamp(progresso, 0.0, 1.0))
			visual_central.scale = Vector2(escala, escala)
			
			if tempo_estado >= TEMPO_INSPIRAR:
				mudar_para_estado(Estado.SEGURAR)
				
		Estado.SEGURAR:
			label_titulo.text = "Segurar..."
			var tempo_restante = ceil(TEMPO_SEGURAR - tempo_estado)
			label_subtitulo.text = str(tempo_restante) + " segundos"
			
			visual_central.scale = Vector2(1.3, 1.3)
			
			if tempo_estado >= TEMPO_SEGURAR:
				mudar_para_estado(Estado.SOLTAR)
				
		Estado.SOLTAR:
			label_titulo.text = "Soltar o ar..."
			var tempo_restante = ceil(TEMPO_SOLTAR - tempo_estado)
			label_subtitulo.text = str(tempo_restante) + " segundos"
			
			var progresso = tempo_estado / TEMPO_SOLTAR
			var escala = lerp(1.3, 1.0, clamp(progresso, 0.0, 1.0))
			visual_central.scale = Vector2(escala, escala)
			
			if tempo_estado >= TEMPO_SOLTAR:
				concluir_exercicio()

func mudar_para_estado(novo_estado):
	estado_atual = novo_estado
	tempo_estado = 0.0

# --- PONTES INTELIGENTES DE HARDWARE ---

func _on_hardware_pressionado():
	# Verifica se o cursor virtual está realmente em cima da nuvem antes de iniciar
	if _cursor_esta_na_nuvem():
		print("-> Nuvem ativada via botão físico do ESP32!")
		_on_nuvem_pressionada()

func _on_hardware_solto():
	# Se a criança estava respirando e soltou o botão físico, aciona a perda
	if estado_atual == Estado.INSPIRAR or estado_atual == Estado.SEGURAR:
		print("-> Botão físico solto antes da hora.")
		_on_nuvem_solta()

# Função auxiliar para validar se a mira do jogo está em cima da nuvem
func _cursor_esta_na_nuvem() -> bool:
	if not visual_central or not visual_central.visible:
		return false
		
	var posicao_cursor = get_viewport().get_mouse_position()
	if has_node("/root/CursorVirtual") and "posicao_cursor" in get_node("/root/CursorVirtual"):
		posicao_cursor = get_node("/root/CursorVirtual").posicao_cursor
		
	return visual_central.get_global_rect().has_point(posicao_cursor)

# --- MECÂNICA DE TOQUE E PRESSÃO ---

func _on_nuvem_pressionada():
	if estado_atual == Estado.PARADO or estado_atual == Estado.SOLTAR:
		visual_central.pivot_offset = visual_central.size / 2
		mudar_para_estado(Estado.INSPIRAR)

func _on_nuvem_solta():
	if estado_atual == Estado.INSPIRAR or estado_atual == Estado.SEGURAR:
		label_subtitulo.text = "Ops! Soltou antes da hora. Tente de novo!"
		mudar_para_estado(Estado.SOLTAR)

func concluir_exercicio():
	estado_atual = Estado.CONCLUIDO
	label_titulo.text = "Muito bem!"
	label_subtitulo.text = "Você conseguiu se acalmar!"
	visual_central.scale = Vector2(1.0, 1.0)
	
	await get_tree().create_timer(1.5).timeout
	Global.mudar_fase(Global.TELA_FEEDBACK)
