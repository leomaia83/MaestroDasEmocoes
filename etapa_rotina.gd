extends Control

@export var imagem_tarefa: Texture2D
var nome_etapa: String = ""
var arrastando: bool = false
var posicao_original: Vector2
var pai_original: Node

@onready var jogo_principal = get_tree().current_scene

func _ready():
	if imagem_tarefa != null and has_node("TextureRect"):
		$TextureRect.texture = imagem_tarefa
		
	nome_etapa = name
	pai_original = get_parent()
	
	# Espera a interface se desenhar para salvar a posição inicial correta
	await get_tree().process_frame
	posicao_original = global_position

	# Conecta diretamente ao barramento físico do ESP32
	if has_node("/root/ControleSerial"):
		var controle = get_node("/root/ControleSerial")
		if controle.botao_hardware_pressionado.is_connected(_on_hardware_pressionado):
			controle.botao_hardware_pressionado.disconnect(_on_hardware_pressionado)
		if controle.botao_hardware_solto.is_connected(_on_hardware_solto):
			controle.botao_hardware_solto.disconnect(_on_hardware_solto)
			
		controle.botao_hardware_pressionado.connect(_on_hardware_pressionado)
		controle.botao_hardware_solto.connect(_on_hardware_solto)

func _process(_delta):
	if arrastando:
		var pos_cursor = get_viewport().get_mouse_position()
		if has_node("/root/CursorVirtual") and "posicao_cursor" in get_node("/root/CursorVirtual"):
			pos_cursor = get_node("/root/CursorVirtual").posicao_cursor
		
		# Move o card centralizado na ponta do cursor virtual
		global_position = pos_cursor - (size / 2)

func _on_hardware_pressionado():
	if not is_instance_valid(jogo_principal):
		jogo_principal = get_tree().current_scene

	# Agora que criamos a variável no rotina.gd, essa checagem vai funcionar!
	if jogo_principal.get("etapa_sendo_arrastada") == null and _cursor_esta_sobre_mim():
		arrastando = true
		jogo_principal.etapa_sendo_arrastada = self
		z_index = 100 
		print("-> Arrastando tarefa: ", nome_etapa)

func _on_hardware_solto():
	if arrastando:
		arrastando = false
		jogo_principal.etapa_sendo_arrastada = null
		z_index = 0
		
		var slot_alvo = _procurar_slot_sob_cursor()
		
		if slot_alvo and slot_alvo.etapa_no_slot == null:
			if get_parent() != pai_original and get_parent().has_method("get"):
				get_parent().etapa_no_slot = null
				
			get_parent().remove_child(self)
			slot_alvo.add_child(self)
			slot_alvo.etapa_no_slot = self
			
			position = Vector2.ZERO
			print("-> Tarefa encaixada com sucesso no ", slot_alvo.name)
		else:
			if get_parent() != pai_original:
				if get_parent().has_method("get"):
					get_parent().etapa_no_slot = null
				get_parent().remove_child(self)
				pai_original.add_child(self)
			
			global_position = posicao_original
			print("-> Solto fora. Retornando para a grade.")

func _cursor_esta_sobre_mim() -> bool:
	var pos = get_viewport().get_mouse_position()
	if has_node("/root/CursorVirtual") and "posicao_cursor" in get_node("/root/CursorVirtual"):
		pos = get_node("/root/CursorVirtual").posicao_cursor
	return get_global_rect().has_point(pos)

func _procurar_slot_sob_cursor() -> Control:
	var pos = get_viewport().get_mouse_position()
	if has_node("/root/CursorVirtual") and "posicao_cursor" in get_node("/root/CursorVirtual"):
		pos = get_node("/root/CursorVirtual").posicao_cursor
		
	var container_slots = jogo_principal.get_node("HBoxContainer/VBoxContainer")
	if container_slots:
		for slot in container_slots.get_children():
			if slot.visible and slot.get_global_rect().has_point(pos):
				return slot
	return null
