extends CanvasLayer

const VELOCIDADE_CURSOR = 600.0 
var posicao_cursor = Vector2.ZERO
var cursor_visual: ColorRect

func _ready():
	# Coloca o quadrado no centro da tela do jogo automaticamente
	var tamanho_tela = get_viewport().get_visible_rect().size
	posicao_cursor = tamanho_tela / 2
	
	# Configura o visual do quadrado vermelho
	cursor_visual = ColorRect.new()
	cursor_visual.size = Vector2(20, 20) # Um pouco maior para enxergar bem!
	cursor_visual.color = Color(1, 0, 0, 1) # Vermelho puro
	cursor_visual.position = posicao_cursor
	
	# Adiciona na tela
	add_child(cursor_visual)
	print("Quadrado do cursor criado na posição: ", posicao_cursor)

func _process(delta):
	# Pega a direção atual calculada pelo ControleSerial
	var direcao = Vector2(ControleSerial.eixo_x, ControleSerial.eixo_y)
	
	# Se a direção não for zero, significa que o sinal do ESP32 chegou!
	if direcao != Vector2.ZERO:
		print("Movendo cursor. Direção do analógico: ", direcao)
		
		# Atualiza a posição na tela
		posicao_cursor += direcao * VELOCIDADE_CURSOR * delta
		
		var tamanho_tela = get_viewport().get_visible_rect().size
		posicao_cursor.x = clamp(posicao_cursor.x, 0, tamanho_tela.x)
		posicao_cursor.y = clamp(posicao_cursor.y, 0, tamanho_tela.y)
		
		# Atualiza o quadrado visual e o mouse interno do Godot
		cursor_visual.position = posicao_cursor
		get_viewport().warp_mouse(posicao_cursor)
