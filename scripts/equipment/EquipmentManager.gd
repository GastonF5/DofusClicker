class_name EquipmentManager
extends Node


@export var equipment_container: PanelContainer


var slots = []


func _ready():
	for container in equipment_container.get_children():
		for slot in container.get_children():
			slots.append(slot)
			slot.mouse_entered.connect(_on_mouse_entered_slot.bind(slot))
			slot.mouse_exited.connect(Inventory._on_mouse_exited_slot)


func _on_mouse_entered_slot(slot):
	var dragged_item = PlayerManager.dragged_item
	if dragged_item != null and dragged_item.resource.equip_res != null:
		Inventory._on_mouse_entered_slot(slot)


func dict_contains_key(dict: Dictionary, key: String) -> bool:
	return dict.keys().has(key)
