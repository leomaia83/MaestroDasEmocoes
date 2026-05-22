extends Control

@onready var botao_respirar = $BotaoRespirar
@onready var progresso_barra = $ProgressBar
@onready var balao = $Balao

var tempo_pressionado : float = 0.0
const TEMPO_NECESSARIO : float = 3.0

func _ready():
	progresso_barra.max_value = TEMPO_NECESSARIO
	progresso_barra.value = 0.0

func _process(delta):
	if botao_respirar.button_pressed:
		tempo_pressionado += delta
		progresso_barra.value = tempo_pressionado
		var f = 1.0 + (tempo_pressionado / TEMPO_NECESSARIO) * 0.5
		balao.scale = Vector2(f, f)
		
		if tempo_pressionado >= TEMPO_NECESSARIO:
			concluir()
	else:
		if tempo_pressionado > 0.0:
			tempo_pressionado -= delta * 2.0
			tempo_pressionado = max(tempo_pressionado, 0.0)
			progresso_barra.value = tempo_pressionado
			var f = 1.0 + (tempo_pressionado / TEMPO_NECESSARIO) * 0.5
			balao.scale = Vector2(f, f)

func concluir():
	set_process(false)
	await get_tree().create_timer(1.0).timeout
	Global.mudar_fase(Global.TELA_FEEDBACK)
