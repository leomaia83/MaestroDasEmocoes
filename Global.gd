extends Node

var humor_do_dia : String = ""
var motivo_do_humor : String = ""

# Lista atualizada com os nomes exatos que você está usando nas transições
var fluxo_do_jogo = [
	"res://check_in_emocional.tscn",
	"res://causas_humor.tscn",
	"res://botao_calma.tscn",
	"res://diver_tix.tscn",
	"res://tela_feedback.tscn"
]

var fase_atual = 0

func mudar_fase(caminho_da_fase: String):
	get_tree().change_scene_to_file(caminho_da_fase)

func ir_para_proxima():
	fase_atual += 1
	if fase_atual < fluxo_do_jogo.size():
		mudar_fase(fluxo_do_jogo[fase_atual])
	else:
		fase_atual = 0
		mudar_fase(fluxo_do_jogo[0])
