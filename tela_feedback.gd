extends Control

@onready var container_estrelas = $VBoxContainer/HBoxContainer

func _ready():
	# Começamos com todas as estrelas invisíveis (escala 0)
	for estrela in container_estrelas.get_children():
		estrela.scale = Vector2.ZERO
		estrela.pivot_offset = estrela.size / 2 # Garante que cresçam do centro
	
	animar_vitoria()

func animar_vitoria():
	var tempo_espera = 0.3
	for estrela in container_estrelas.get_children():
		# Cria um "Tween" para animar cada estrela
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		
		# Espera um pouquinho antes de mostrar a próxima estrela
		await get_tree().create_timer(tempo_espera).timeout
		
		# Faz a estrela crescer com efeito de mola
		tween.tween_property(estrela, "scale", Vector2(1, 1), 0.5)
		# Tocar um som de "Plim!" aqui seria perfeito!

func _on_botao_jogar_novamente_pressed():
	Global.mudar_fase("res://CheckInEmocional.tscn")

func _on_botao_sair_pressed():
	get_tree().quit()
