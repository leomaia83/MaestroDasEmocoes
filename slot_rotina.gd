extends Control

# Permite arrastar a imagem do slot com o número pelo Inspetor
@export var imagem_slot: Texture2D
var ordem_correta: int = 0
var etapa_no_slot: Control = null

func _ready():
	if imagem_slot != null:
		$TextureRect.texture = imagem_slot
	
	# Define automaticamente a ordem baseado na posição do nó (Slot1 = 0, Slot2 = 1...)
	ordem_correta = get_index()

func _can_drop_data(position, data):
	return data is Control and data.has_method("_get_drag_data") and etapa_no_slot == null

func _drop_data(position, data):
	etapa_no_slot = data
	etapa_no_slot.get_parent().remove_child(etapa_no_slot)
	add_child(etapa_no_slot)
	etapa_no_slot.position = Vector2.ZERO
	etapa_no_slot.visible = true
