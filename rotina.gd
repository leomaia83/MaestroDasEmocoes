extends Control

# Referências dos contêineres na árvore
@onready var container_etapas = $HBoxContainer/GridContainer
@onready var container_slots = $HBoxContainer/VBoxContainer
@onready var botao_verificar = $ButtonVerificar

# Lógica do Jogo
const TOTAL_ETAPAS = 6
# Defina a ordem correta das etapas aqui, mapeando o nome da etapa para a posição (0-5)
const ORDEM_CORRETA = {
	"Acordar": 0,
	"Escovar os dentes": 1,
	"Tomar café": 2,
	"Vestir a roupa": 3,
	"Ir para a escola": 4,
	"Guardar a mochila": 5
}

func _ready():
	# Conecta o botão de verificação lá de baixo
	botao_verificar.pressed.connect(_on_botao_verificar_pressionado)

func _on_botao_verificar_pressionado():
	var acertos = 0
	
	# Percorre os slots para verificar a ordem
	for i in range(TOTAL_ETAPAS):
		var slot = container_slots.get_child(i)
		if slot.etapa_no_slot != null:
			if ORDEM_CORRETA[slot.etapa_no_slot.nome_etapa] == slot.ordem_correta:
				acertos += 1
				print("Acertou a etapa ", slot.etapa_no_slot.nome_etapa)
			else:
				print("Errou a etapa ", slot.etapa_no_slot.nome_etapa)
		else:
			print("Slot ", i+1, " está vazio.")
			
	# Verifica se acertou todas as etapas
	if acertos == TOTAL_ETAPAS:
		print("Rotina montada corretamente!")
		Global.mudar_fase(Global.TELA_FEEDBACK)
	else:
		print("Alguma etapa está na ordem errada. Tente novamente!")
