extends Control

@onready var grid_tarefas = $GridContainer
var ordem_cliques : Array = []
const TOTAL_TAREFAS : int = 3

func _ready():
	print("Minijogo de Rotina iniciado.")
	for botao in grid_tarefas.get_children():
		botao.pressed.connect(_on_tarefa_concluida.bind(botao))

func _on_tarefa_concluida(botao: Button):
	if not ordem_cliques.has(botao):
		ordem_cliques.append(botao)
		botao.modulate = Color(0.5, 1.5, 0.5) # Fica verdinho marcando feito
		botao.disabled = true
		
		if ordem_cliques.size() >= TOTAL_TAREFAS:
			await get_tree().create_timer(1.0).timeout
			Global.mudar_fase(Global.TELA_FEEDBACK)
