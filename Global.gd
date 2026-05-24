extends Node

var humor_do_dia : String = ""
var motivo_do_humor : String = ""

# Caminhos básicos de interface
const TELA_CHECKIN = "res://check_in_emocional.tscn"
const TELA_CAUSAS = "res://causas_humor.tscn"
const TELA_FEEDBACK = "res://tela_feedback.tscn"

# As 6 rotas exclusivas de minijogos (1 para cada emoção)
const SCENE_BRAVO = "res://botao_calma.tscn"
const SCENE_ASSUSTADO = "res://ritmo.tscn"
const SCENE_TRISTE = "res://ajudas.tscn"
const SCENE_CANSADO = "res://rotina.tscn"
const SCENE_FELIZ = "res://memoria.tscn"
const SCENE_ORGULHOSO = "res://termometro.tscn" # A nova emoção adicionada!

const CAMINHO_LOG_CLINICO = "user://historico_emocional_terapeuta.txt"

func mudar_fase(caminho_da_fase: String):
	print("Global: Tentando mudar para a fase: ", caminho_da_fase)
	
	if caminho_da_fase == "" or caminho_da_fase == null:
		print("ERRO GLOBAL: O caminho enviado está vazio ou nulo!")
		return

	var erro = get_tree().change_scene_to_file(caminho_da_fase)
	
	if erro != OK:
		print("ERRO GLOBAL: Falha ao carregar a cena! Código do erro: ", erro)
		print("Verifique se o arquivo existe e se não tem nenhum script quebrado dentro dele.")

func definir_proximo_minijogo():
	salvar_dados_no_historico()
	
	# Distribuição exata e inteligente para cada um dos 6 botões
	match humor_do_dia:
		"Bravo":
			mudar_fase(SCENE_BRAVO)
		"Assustado":
			mudar_fase(SCENE_ASSUSTADO)
		"Triste":
			mudar_fase(SCENE_TRISTE)
		"Cansado", "Entediado":
			mudar_fase(SCENE_CANSADO)
		"Feliz", "Calmo", "Bem":
			mudar_fase(SCENE_FELIZ)
		"Orgulhoso":
			mudar_fase(SCENE_ORGULHOSO)
		_:
			mudar_fase(SCENE_FELIZ)

func salvar_dados_no_historico():
	var data_hora = Time.get_datetime_dict_from_system()
	var timestamp = "%02d/%02d/%04d às %02d:%02d" % [data_hora.day, data_hora.month, data_hora.year, data_hora.hour, data_hora.minute]
	var linha_registro = "[%s] Emoção: %s | Motivo: %s\n" % [timestamp, humor_do_dia, motivo_do_humor]
	
	var arquivo = FileAccess.open(CAMINHO_LOG_CLINICO, FileAccess.READ_WRITE)
	if arquivo == null:
		arquivo = FileAccess.open(CAMINHO_LOG_CLINICO, FileAccess.WRITE)
	else:
		arquivo.seek_end()
	arquivo.store_string(linha_registro)
	arquivo.close()
