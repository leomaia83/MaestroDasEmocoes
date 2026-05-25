extends Node

signal botao_hardware_pressionado
signal botao_hardware_solto

var porta_com = "COM3" # Porta física da sua protoboard
var thread: Thread
var rodando = true

var eixo_x: float = 0.0
var eixo_y: float = 0.0
var botao_estava_apertado = false

func _ready():
	print("Iniciando leitura nativa do cabo USB na porta: ", porta_com)
	thread = Thread.new()
	thread.start(_ler_porta_serial)

func _ler_porta_serial():
	var comando = "cmd.exe"
	# Executa o comando do Windows que joga os dados da porta serial direto no terminal
	var argumentos = ["/c", "mode %s BAUD=115200 PARITY=n DATA=8 STOP=1 dtr=on rts=on && type %s" % [porta_com, porta_com]]
	
	var resultado = OS.execute_with_pipe(comando, argumentos)
	var pipe = resultado["stdio"]
	
	# Usamos is_open() e checamos se o Godot consegue extrair dados do canal
	while rodando and pipe.is_open():
		if pipe.get_error() == OK:
			var linha = pipe.get_line().strip_edges()
			if linha != "" and "," in linha:
				# Envia os dados para processar na tela principal sem travar o jogo
				call_deferred("_processar_dados_serial", linha)
		# Uma pequena pausa de 10ms para não estressar o processador do PC
		OS.delay_msec(10)

func _processar_dados_serial(dados: String):
	var partes = dados.split(",")
	if partes.size() < 3:
		return
		
	var x_val = partes[0].to_int()
	var y_val = partes[1].to_int()
	var btn_val = partes[2].to_int()
	
	# Transforma o range do ESP32 (0 a 4095) para o do Godot (-1.0 a 1.0)
	eixo_x = (x_val - 2048.0) / 2048.0
	eixo_y = (y_val - 2048.0) / 2048.0
	
	# Zona morta para estabilizar o analógico em repouso
	if abs(eixo_x) < 0.15: eixo_x = 0.0
	if abs(eixo_y) < 0.15: eixo_y = 0.0
	
	# Gerencia o clique do botão vermelho
	if btn_val == 0 and not botao_estava_apertado:
		botao_estava_apertado = true
		emit_signal("botao_hardware_pressionado")
		_simular_clique_mouse(true)
	elif btn_val == 1 and botao_estava_apertado:
		botao_estava_apertado = false
		emit_signal("botao_hardware_solto")
		_simular_clique_mouse(false)

func _simular_clique_mouse(pressionado: bool):
	var evento = InputEventMouseButton.new()
	evento.button_index = MOUSE_BUTTON_LEFT
	evento.pressed = pressionado
	evento.position = get_viewport().get_mouse_position()
	Input.parse_input_event(evento)

func _exit_tree():
	# Finaliza a linha de comando do Windows de forma limpa ao fechar o jogo
	rodando = false
	if thread and thread.is_started():
		thread.wait_to_finish()
