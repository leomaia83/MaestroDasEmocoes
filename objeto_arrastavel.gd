extends Area2D

var segurando = false
var offset = Vector2.ZERO
var posicao_inicial = Vector2.ZERO

func _ready():
	posicao_inicial = global_position # Guarda onde o objeto começou

func _input_event(_viewport, event, _shape_idx):
	# Detecta se o jogador clicou no objeto
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			segurando = true
			offset = global_position - get_global_mouse_position()
		else:
			segurando = false
			verificar_posicao()

func _process(_delta):
	# Se estiver segurando, o objeto segue o mouse
	if segurando:
		global_position = get_global_mouse_position() + offset

func verificar_posicao():
	var areas = get_overlapping_areas()
	var acerto = false
	
	for area in areas:
		if area.is_in_group("destino_correto"):
			print("Acertou!")
			global_position = area.global_position # "Gruda" no lugar certo
			acerto = true
			
			# AQUI: Avisa o script pai (DiverTIX) que o desafio foi concluído
			if get_parent().has_method("desfecho_vitoria"):
				get_parent().desfecho_vitoria()
	
	if not acerto:
		global_position = posicao_inicial
