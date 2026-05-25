extends Control

# Permite arrastar a imagem direto pelo Inspetor
@export var imagem_tarefa: Texture2D
var nome_etapa: String = ""

func _ready():
	# Se colocamos uma imagem no Inspetor, ela será aplicada ao TextureRect
	if imagem_tarefa != null:
		$TextureRect.texture = imagem_tarefa
		
	# Define o nome interno baseado no nome do próprio nó na árvore
	nome_etapa = name

func _get_drag_data(position):
	# Cria a prévia visual idêntica ao arrastar
	var drag_preview = TextureRect.new()
	drag_preview.texture = imagem_tarefa
	drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	drag_preview.custom_minimum_size = Vector2(220, 220)
	set_drag_preview(drag_preview)
	
	return self
