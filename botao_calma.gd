extends Control

# Referências corretas baseadas na sua árvore de nós real!
@onready var label_titulo = $MarginContainer/VBoxContainer/LabelTitulo
@onready var label_subtitulo = $MarginContainer/VBoxContainer/LabelSubtitulo

# O elemento central que tem a nuvem e vai pulsar/crescer:
@onready var visual_central = $MarginContainer/VBoxContainer/CentroAnimacao/VisualCentral

# O botão de suporte que está solto na raiz:
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
	print("Minijogo Botão Calma Iniciado - Nuvem Interativa.")
	
	label_titulo.text = "Respire com o Maestro"
	label_subtitulo.text = "Leve a seta até a nuvem e segure o botão vermelho!"
	
	if visual_central:
		visual_central.pivot_offset = visual_central.size / 2
		visual_central.scale = Vector2(1.0, 1.0)
		
		# O próprio cursor virtual vai ativar isso quando estiver em cima da nuvem!
		visual_central.button_down.connect(_on_nuvem_pressionada)
		visual_central.button_up.connect(_on_nuvem_solta)

func _process(delta):
	if estado_atual == Estado.PARADO or estado_atual == Estado.CONCLUIDO:
		return
		
	tempo_estado += delta
	
	match estado_atual:
		Estado.INSPIRAR:
			label_titulo.text = "Inspirar..."
			
			# Calcula o tempo restante (Contagem regressiva arredondada para cima)
			var tempo_restante = ceil(TEMPO_INSPIRAR - tempo_estado)
			label_subtitulo.text = str(tempo_restante) + " segundos"
			
			var progresso = tempo_estado / TEMPO_INSPIRAR
			var escala = lerp(1.0, 1.3, clamp(progresso, 0.0, 1.0))
			visual_central.scale = Vector2(escala, escala)
			
			if tempo_estado >= TEMPO_INSPIRAR:
				mudar_para_estado(Estado.SEGURAR)
				
		Estado.SEGURAR:
			label_titulo.text = "Segurar..."
			
			# Calcula o tempo restante para segurar o ar
			var tempo_restante = ceil(TEMPO_SEGURAR - tempo_estado)
			label_subtitulo.text = str(tempo_restante) + " segundos"
			
			visual_central.scale = Vector2(1.3, 1.3)
			
			if tempo_estado >= TEMPO_SEGURAR:
				mudar_para_estado(Estado.SOLTAR)
				
		Estado.SOLTAR:
			label_titulo.text = "Soltar o ar..."
			
			# Calcula o tempo restante para esvaziar o ar
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

# --- MECÂNICA DE TOQUE E PRESSÃO (TELA OU HARDWARE) ---

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
