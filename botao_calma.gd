extends Control

@onready var timer = $Timer
@onready var barra = $ProgressBar

func _process(_delta):
	if not timer.is_stopped():
		# A barra enche conforme o timer corre
		barra.value = (1.0 - (timer.time_left / timer.wait_time)) * 100

func _on_button_button_down():
	timer.start() # Começa a contar quando aperta
	# Aqui você daria play numa música relaxante

func _on_button_button_up():
	if timer.time_left > 0:
		print("Soltou cedo demais!")
		timer.stop()
		barra.value = 0
	else:
		print("Muito bem! Você se acalmou.")
		# AQUI: Após se acalmar, leva a criança para jogar o DiverTIX!
		Global.mudar_fase("res://DiverTIX.tscn")
