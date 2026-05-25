extends Control

# Certifique-se de conectar os sinais 'pressed()' desses botões no painel "Nó" ao lado do Inspetor!

func _on_button_jogar_novamente_pressed():
	print("Reiniciando o jogo...")
	# Redireciona de volta para a primeira fase do jogo (ex: o check-in emocional ou a memória)
	Global.mudar_fase("res://check_in_emocional.tscn") 

func _on_button_voltar_inicio_pressed():
	print("Voltando para a tela inicial...")
	# Redireciona para o menu principal do seu jogo
	Global.mudar_fase("res://menu_principal.tscn")
