class_name EquipmentManager
extends Node


@export var equipment_container: GridContainer

@onready var console: Console = $"%Console"

var slots = []

signal equiped
signal desequiped


func _ready():
	for slot in equipment_container.get_children():
		slots.append(slot)
		slot.mouse_entered.connect(_on_mouse_entered_slot.bind(slot))
		slot.mouse_exited.connect(Inventory._on_mouse_exited_slot)
		slot.child_entered_tree.connect(on_equiped)
		slot.child_exiting_tree.connect(on_desequiped)


func on_equiped(item: Item):
	if !item.resource.equip_res:
		console.log_error("L'item équipé n'est pas un équipement : " + item.name)
		return
	equiped.emit(item)


func on_desequiped(item: Item):
	if !item.resource.equip_res:
		console.log_error("L'item déséquipé n'est pas un équipement : " + item.name)
		return
	desequiped.emit(item)


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


func get_equipment():
	return slots.map(func(s): return null if s.get_children().size() != 0 else s.get_child(0)).filter(func(e): return e != null)
