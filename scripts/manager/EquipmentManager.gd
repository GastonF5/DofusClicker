extends Node


const EMPTY_SLOT_TEXTURE_PATH = "res://assets/equipment/slots/emptySlot.png"
const SLOT_TEXTURE_PATH = "res://assets/equipment/slots/%s.png"

var equipment_container: EquipmentContainer
var inventory: Inventory

signal equiped
signal desequiped


func initialize():
	equipment_container = get_tree().current_scene.get_node("%EquipmentContainer")
	inventory = Globals.inventory
	for slot in equipment_container.slots:
		slot.mouse_entered.connect(_on_mouse_entered_slot.bind(slot))
		slot.mouse_exited.connect(inventory.set_dragged_exited_drop_parent)
		slot.child_entered_tree.connect(on_equiped.bind(slot))
		slot.child_exiting_tree.connect(on_desequiped.bind(slot))


func on_equiped(item: Item, slot):
	if !item.resource.equip_res:
		Globals.console.log_error("L'item équipé n'est pas un équipement : " + item.name)
		return
	slot.get_child(0).texture = load(EMPTY_SLOT_TEXTURE_PATH)
	equiped.emit(item)


func on_desequiped(item: Item, slot):
	if !item.resource.equip_res:
		Globals.console.log_error("L'item déséquipé n'est pas un équipement : " + item.name)
		return
	slot.get_child(0).texture = load(SLOT_TEXTURE_PATH % item.resource.equip_res.get_type().to_lower())
	desequiped.emit(item)


func _on_mouse_entered_slot(slot):
	var dragged_item = PlayerManager.dragged_item
	if dragged_item != null and dragged_item.resource.equip_res != null:
		if slot.name.contains(dragged_item.resource.equip_res.get_type().to_pascal_case()):
			inventory.set_dragged_entering_drop_parent(slot)


func dict_contains_key(dict: Dictionary, key: String) -> bool:
	return dict.keys().has(key)


static func is_equip_slot(slot):
	return slot and slot.get_groups().has("equipment_slot")
