extends Control

# Referências dos contêineres na árvore (exatamente como no seu original)
@onready var container_etapas = $HBoxContainer/GridContainer
@onready var container_slots = $HBoxContainer/VBoxContainer
@onready var botao_verificar = $ButtonVerificar

# 🔥 Variável de controle para o sistema de drag customizado por hardware
var etapa_sendo_arrastada: Control = null

# Lógica do Jogo
const TOTAL_ETAPAS = 6
const ORDEM_CORRETA = {
	"Acordar": 0,
	"Escovar os dentes": 1,
	"Tomar café": 2,
	"Vestir a roupa": 3,
	"Ir para a escola": 4,
	"Guardar a mochila": 5
}

func _ready():
	print("Minijogo Rotina Iniciado - Sistema Drag Customizado por Hardware.")
	
	# Configura o botão verificar para clique limpo e sem foco automático do teclado
	if botao_verificar:
		botao_verificar.focus_mode = Control.FOCUS_NONE
		botao_verificar.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		
		# Limpa conexões duplicadas por segurança e conecta
		if botao_verificar.pressed.is_connected(_on_botao_verificar_pressionado):
			botao_verificar.pressed.disconnect(_on_botao_verificar_pressionado)
		botao_verificar.pressed.connect(_on_botao_verificar_pressionado)

func _on_botao_verificar_pressionado():
	var acertos = 0
	
	# Percorre os slots para verificar a ordem
	for i in range(TOTAL_ETAPAS):
		if container_slots.get_child_count() > i:
			var slot = container_slots.get_child(i)
			if slot.etapa_no_slot != null:
				var nome = slot.etapa_no_slot.nome_etapa
				if ORDEM_CORRETA.has(nome) and ORDEM_CORRETA[nome] == slot.ordem_correta:
					acertos += 1
					print("Acertou a etapa: ", nome)
				else:
					print("Errou a etapa: ", nome)
			else:
				print("Slot ", i+1, " está vazio.")
		else:
			print("Erro: Nó do Slot ", i+1, " não foi encontrado na árvore.")
			
	# Verifica se acertou todas as etapas
	if acertos == TOTAL_ETAPAS:
		print("Rotina montada corretamente!")
		# Remove as travas de cena e avança direto via Global
		Global.mudar_fase(Global.TELA_FEEDBACK)
	else:
		print("Alguma etapa está na ordem errada. Tente novamente!")
