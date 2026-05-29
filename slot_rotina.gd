extends Control

@export var imagem_slot: Texture2D
var ordem_correta: int = 0
var etapa_no_slot: Control = null

func _ready():
	if imagem_slot != null and has_node("TextureRect"):
		$TextureRect.texture = imagem_slot
	
	# Define 0 para o primeiro slot, 1 para o segundo, etc.
	ordem_correta = get_index()
