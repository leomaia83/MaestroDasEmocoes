extends Control

# Referências diretas à sua árvore de nós
@onready var visual_central = $MarginContainer/VBoxContainer/CentroAnimacao/VisualCentral
@onready var label_titulo = $MarginContainer/VBoxContainer/LabelTitulo
@onready var botao_comecar = $MarginContainer/VBoxContainer/HBoxContainer/ButtonComecar

# Estados do exercício de respiração
enum Estado { PARADO, INSPIRAR, SEGURAR, SOLTAR, CONCLUIDO }
var estado_atual = Estado.PARADO
var tempo_estado : float = 0.0

# Tempos do ciclo de respiração
const TEMPO_INSPIRAR = 4.0
const TEMPO_SEGURAR = 2.0
const TEMPO_SOLTAR = 4.0

func _ready():
	# Configura o pivô do botão para expandir a partir do meio
	visual_central.pivot_offset = visual_central.size / 2
	visual_central.scale = Vector2(1.0, 1.0)
	
	# Usamos 'button_down' (quando aperta) e 'button_up' (quando solta)
	if visual_central:
		visual_central.button_down.connect(_on_botao_pressionado)
		visual_central.button_up.connect(_on_botao_solto)
	
	if botao_comecar:
		botao_comecar.button_down.connect(_on_botao_pressionado)
		botao_comecar.button_up.connect(_on_botao_solto)

func _process(delta):
	if estado_atual == Estado.PARADO or estado_atual == Estado.CONCLUIDO:
		return
		
	tempo_estado += delta
	
	match estado_atual:
		Estado.INSPIRAR:
			label_titulo.text = "Inspirar..."
			var progresso = tempo_estado / TEMPO_INSPIRAR
			var escala = lerp(1.0, 1.3, clamp(progresso, 0.0, 1.0))
			visual_central.scale = Vector2(escala, escala)
			
			if tempo_estado >= TEMPO_INSPIRAR:
				mudar_para_estado(Estado.SEGURAR)
				
		Estado.SEGURAR:
			label_titulo.text = "Segurar..."
			visual_central.scale = Vector2(1.3, 1.3)
			
			if tempo_estado >= TEMPO_SEGURAR:
				# Depois de segurar o tempo necessário, começa a soltar automaticamente
				mudar_para_estado(Estado.SOLTAR)
				
		Estado.SOLTAR:
			label_titulo.text = "Soltar o ar..."
			var progresso = tempo_estado / TEMPO_SOLTAR
			var escala = lerp(1.3, 1.0, clamp(progresso, 0.0, 1.0))
			visual_central.scale = Vector2(escala, escala)
			
			if tempo_estado >= TEMPO_SOLTAR:
				concluir_exercicio()

func mudar_para_estado(novo_estado):
	estado_atual = novo_estado
	tempo_estado = 0.0

# --- MECÂNICA DE TOQUE E PRESSÃO ---

func _on_botao_pressionado():
	# Só começa a inspirar se o exercício estiver parado ou voltando ao normal (soltar)
	if estado_atual == Estado.PARADO or estado_atual == Estado.SOLTAR:
		visual_central.pivot_offset = visual_central.size / 2
		mudar_para_estado(Estado.INSPIRAR)

func _on_botao_solto():
	# Se a criança soltar o dedo ANTES de terminar de inspirar ou segurar, o balão murcha (vai direto para SOLTAR)
	if estado_atual == Estado.INSPIRAR or estado_atual == Estado.SEGURAR:
		mudar_para_estado(Estado.SOLTAR)

func concluir_exercicio():
	estado_atual = Estado.CONCLUIDO
	label_titulo.text = "Muito bem!"
	visual_central.scale = Vector2(1.0, 1.0)
	
	await get_tree().create_timer(1.5).timeout
	Global.mudar_fase(Global.TELA_FEEDBACK)
