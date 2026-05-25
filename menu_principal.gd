extends Control

func _ready():
	print("Menu Principal do Maestro iniciado!")

# Conecte o sinal 'pressed()' do ButtonJogar aqui
func _on_button_jogar_pressed():
	print("Iniciando a jornada das emoções...")
	# Redireciona para o primeiro minijogo ou para a tela de check-in emocional
	Global.mudar_fase("res://check_in_emocional.tscn")

func _on_button_configuracoes_pressed():
	print("--- BOTÃO CONFIGURAÇÕES CLICADO COM SUCESSO! ---")
	print("Coordenadas do clique registradas. Posição do botão invisível correta.")
	
	# Opcional: Se você quiser mostrar uma mensagem rápida na própria tela do jogo:
	_mostrar_aviso_na_tela("Configurações em desenvolvimento!")

# Função extra para dar um feedback visual na tela sem precisar criar outra cena
func _mostrar_aviso_na_tela(mensagem: String):
	# Cria um nó de texto via código rapidamente
	var label_aviso = Label.new()
	label_aviso.text = mensagem
	
	# Centraliza o texto na tela
	label_aviso.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_aviso.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_aviso.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# Muda a cor para um roxo ou azul fofo condizente com o tema
	label_aviso.add_theme_color_override("font_color", Color(0.4, 0.3, 0.6))
	label_aviso.add_theme_font_size_override("font_size", 32)
	
	add_child(label_aviso)
	
	# Espera 1.5 segundos e faz o texto sumir sozinho
	await get_tree().create_timer(1.5).timeout
	label_aviso.queue_free()
