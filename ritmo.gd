extends Control

@onready var container_botoes = $HBoxContainer
@onready var timer_ritmo = $TempoRitmo

var sequencia_botoes : Array = []
var botao_ativo_atual : Button = null
var acertos_necessarios : int = 4
var total_acertos : int = 0

func _ready():
	sequencia_botoes = container_botoes.get_children()
	for b in sequencia_botoes:
		b.pressed.connect(_on_click.bind(b))
		b.modulate = Color(0.6, 0.6, 0.6)
	timer_ritmo.wait_time = 1.2
	timer_ritmo.timeout.connect(alternar)
	timer_ritmo.start()
	alternar()

func alternar():
	if botao_ativo_atual != null:
		botao_ativo_atual.modulate = Color(0.6, 0.6, 0.6)
	botao_ativo_atual = sequencia_botoes.pick_random()
	botao_ativo_atual.modulate = Color(1.5, 1.5, 1.5)

func _on_click(b: Button):
	if b == botao_ativo_atual:
		total_acertos += 1
		b.modulate = Color(0.0, 1.5, 0.0)
		if total_acertos >= acertos_necessarios:
			timer_ritmo.stop()
			await get_tree().create_timer(1.0).timeout
			Global.mudar_fase(Global.TELA_FEEDBACK)
