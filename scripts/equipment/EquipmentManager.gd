class_name EquipmentManager
extends Node


@export var equipment_container: GridContainer


var slots = []


func _ready():
	for slot in equipment_container.get_children():
		slots.append(slot)
		slot.mouse_entered.connect(_on_mouse_entered_slot.bind(slot))
		slot.mouse_exited.connect(Inventory._on_mouse_exited_slot)


func _on_mouse_entered_slot(slot):
	var dragged_item = PlayerManager.dragged_item
	if dragged_item != null and dragged_item.resource.equip_res != null:
		if slot.name.contains(dragged_item.resource.equip_res.get_type().to_pascal_case()):
			Inventory._on_mouse_entered_slot(slot)


func dict_contains_key(dict: Dictionary, key: String) -> bool:
	return dict.keys().has(key)


static func is_equip_slot(slot):
	if slot != null:
		return slot.get_groups().has("equipment_slot")
	return false
