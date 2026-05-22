extends Node

var humor_do_dia : String = ""
var motivo_do_humor : String = ""

# Caminhos exatos das suas cenas
const TELA_CHECKIN = "res://check_in_emocional.tscn"
const TELA_CAUSAS = "res://causas_humor.tscn"
const TELA_FEEDBACK = "res://tela_feedback.tscn"

# As 5 cenas exclusivas para cada emoção
const SCENE_BRAVO = "res://BotaoCalma.tscn"
const SCENE_ASSUSTADO = "res://ritmo.tscn"
const SCENE_TRISTE = "res://ajudas.tscn"
const SCENE_CANSADO = "res://rotina.tscn"
const SCENE_FELIZ = "res://memoria.tscn"

const CAMINHO_LOG_CLINICO = "user://historico_emocional_terapeuta.txt"

func mudar_fase(caminho_da_fase: String):
	get_tree().change_scene_to_file(caminho_da_fase)

func definir_proximo_minijogo():
	salvar_dados_no_historico()
	
	# Faz o desvio exato baseado no botão clicado!
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
