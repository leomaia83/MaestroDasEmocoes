extends Node

signal botao_hardware_pressionado
signal botao_hardware_solto

var porta_com = "COM3"
var thread: Thread
var rodando = true

var eixo_x: float = 0.0
var eixo_y: float = 0.0
var botao_estava_apertado = false

var centro_x: float = 2048.0
var centro_y: float = 2048.0
var calibrado: bool = false

# Buffer para acumular os bytes que chegam aos poucos
var buffer_bytes := PackedByteArray()

func _ready():
	print("Iniciando leitura nativa por fluxo de bytes na porta: ", porta_com)
	calibrado = false
	thread = Thread.new()
	thread.start(_ler_porta_serial)

func _ler_porta_serial():
	var comando = "cmd.exe"
	var argumentos = ["/c", "mode %s BAUD=115200 PARITY=n DATA=8 STOP=1 dtr=on rts=on && type %s" % [porta_com, porta_com]]
	
	var resultado = OS.execute_with_pipe(comando, argumentos)
	var pipe = resultado["stdio"]
	
	while rodando and pipe.is_open():
		# Descobre quantos bytes estão mofando no buffer esperando para serem lidos
		var tamanho_disponivel = pipe.get_length() - pipe.get_position()
		
		if tamanho_disponivel > 0:
			# 🔴 CORREÇÃO: Lemos os bytes puros disponíveis usando o get_buffer do FileAccess
			var dados = pipe.get_buffer(tamanho_disponivel)
			
			for i in range(dados.size()):
				var b = dados[i]
				
				# Se achou o fim da linha (\n ou \r)
				if b == 10 or b == 13:
					if buffer_bytes.size() > 0:
						var linha = buffer_bytes.get_string_from_utf8().strip_edges()
						buffer_bytes.clear() # Limpa para acumular a próxima linha
						
						if "," in linha:
							call_deferred("_processar_dados_serial", linha)
				else:
					# Filtro ultra-rigoroso: só guarda o que for número ou vírgula
					if (b >= 48 and b <= 57) or b == 44:
						buffer_bytes.append(b)
						
		OS.delay_msec(5) # Ciclo rápido para capturar o clique instantaneamente

func _processar_dados_serial(dados: String):
	var partes = dados.split(",")
	if partes.size() < 3:
		return
		
	var x_val = partes[0].to_int()
	var y_val = partes[1].to_int()
	var btn_val = partes[2].to_int()
	
	# Ignora leituras zeradas fantasmas
	if x_val == 0 and y_val == 0 and btn_val == 0:
		return

	if not calibrado and x_val > 500 and y_val > 500:
		centro_x = float(x_val)
		centro_y = float(y_val)
		calibrado = true
		print("Hardware Calibrado! Neutro: X=", centro_x, " Y=", centro_y)
		return

	# Processamento dos eixos analógicos
	if x_val >= centro_x:
		eixo_x = (x_val - centro_x) / (4095.0 - centro_x if 4095.0 - centro_x != 0 else 1.0)
	else:
		eixo_x = (x_val - centro_x) / (centro_x if centro_x != 0 else 1.0)
		
	if y_val >= centro_y:
		eixo_y = (y_val - centro_y) / (4095.0 - centro_y if 4095.0 - centro_y != 0 else 1.0)
	else:
		eixo_y = (y_val - centro_y) / (centro_y if centro_y != 0 else 1.0)
	
	if abs(eixo_x) < 0.25: eixo_x = 0.0
	if abs(eixo_y) < 0.25: eixo_y = 0.0
	
	# Detecta o clique do botão físico (0 = Pressionado)
	var botao_pressionado_físico = (btn_val == 0) 

	if botao_pressionado_físico and not botao_estava_apertado:
		botao_estava_apertado = true
		print("-> SINAL HARDWARE: Botão Detectado com Sucesso!")
		emit_signal("botao_hardware_pressionado")
		call_deferred("_disparar_clique", true)
	elif not botao_pressionado_físico and botao_estava_apertado:
		botao_estava_apertado = false
		emit_signal("botao_hardware_solto")
		call_deferred("_disparar_clique", false)

func _disparar_clique(pressionado: bool):
	if not pressionado:
		return

	# 1. Tenta acionar o botão que já está focado pelo sistema de UI
	var no_focado = get_viewport().gui_get_focus_owner()
	if no_focado and no_focado is Button:
		print("-> Forçando clique no botão focado via UI: ", no_focado.name)
		no_focado.emit_signal("pressed")
		return

	# 2. Se o foco se perdeu, pega a posição do cursor virtual
	var posicao_alvo = get_viewport().get_mouse_position()
	if has_node("/root/CursorVirtual") and "posicao_cursor" in get_node("/root/CursorVirtual"):
		posicao_alvo = get_node("/root/CursorVirtual").posicao_cursor
		
	var todos_botoes = get_tree().current_scene.find_children("*", "Button", true, false)
	
	# Verifica se o cursor está fisicamente em cima de algum botão
	for botao in todos_botoes:
		if botao.visible and not botao.disabled:
			var rect = botao.get_global_rect()
			if rect.has_point(posicao_alvo):
				print("-> Cursor detectado sobre o botão: ", botao.name, ". Forçando clique!")
				botao.emit_signal("pressed")
				return
				
	# 3. CASO DE EMERGÊNCIA (Cursor voou para fora da tela por causa do analógico)
	print("-> Emergência: Cursor fora de alcance. Escolhendo botão principal válido...")
	
	# Criamos uma lista de prioridades para evitar clicar no "ButtonVerDeNovo" sem querer
	for botao in todos_botoes:
		if botao.visible and not botao.disabled:
			var nome = botao.name.to_lower()
			
			# IGNORA botões de controle/áudio na hora da emergência
			if "ver" in nome or "novo" in nome or "voltar" in nome or "audio" in nome:
				continue
				
			# Se chegou aqui, é um botão de opção real (Casa, Escola, Feliz, Triste, etc.)
			print("-> Emergência resolvida com sucesso! Forçando clique no botão principal: ", botao.name)
			botao.emit_signal("pressed")
			return

func _exit_tree():
	rodando = false
	if thread and thread.is_started():
		thread.wait_to_finish()
