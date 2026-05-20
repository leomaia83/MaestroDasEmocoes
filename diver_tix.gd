extends Node2D

# Referência automática para o objeto arrastável na cena
@onready var objeto = $ObjetoArrastavel

func _ready():
	print("DiverTIX iniciado! Arraste o objeto até o destino correto.")

# Esta função é acionada pelo script do seu ObjetoArrastavel quando ele acerta o alvo
func desfecho_vitoria():
	print("Desafio concluído! Iniciando transição para o feedback positivo.")
	
	# Criamos um efeito visual simples: faz o objeto piscar um pouco para comemorar
	var tween = create_tween()
	tween.tween_property(objeto, "modulate:a", 0.3, 0.2)
	tween.tween_property(objeto, "modulate:a", 1.0, 0.2)
	
	# Aguarda 1.5 segundos para a criança absorver o sucesso da ação motora
	await get_tree().create_timer(1.5).timeout
	
	# Avança para a tela final de estrelas
	# OBS: Se o seu arquivo na pasta for com letras maiúsculas, mude para "TelaFeedback.tscn"
	Global.mudar_fase("res://tela_feedback.tscn")
