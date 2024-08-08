class_name SlotContainer
extends Control


var slots = []

signal item_entered_tree
signal item_exiting_tree

var console: Console
var slot_group_name: String
var dragged: DraggableControl


func _ready():
	console = Globals.console
	for slot in get_tree().get_nodes_in_group(slot_group_name):
		slots.append(slot)
		connect_slot_signals(slot)


func connect_slot_signals(slot):
	slot.mouse_entered.connect(set_dragged_entering_drop_parent.bind(slot))
	slot.mouse_exited.connect(set_dragged_exited_drop_parent)


func set_dragged_entering_drop_parent(slot):
	if dragged:
		dragged.drop_parent = slot


func set_dragged_exited_drop_parent():
	if dragged:
		if EquipmentManager.is_equip_slot(dragged.old_parent):
			var slot = Globals.inventory.get_first_empty_slot()
			dragged.drop_parent = Globals.inventory.get_first_empty_slot()
		else:
			dragged.drop_parent = dragged.old_parent


func get_empty_slots():
	return slots.filter(func(s): return slot_is_empty(s))


func slot_is_empty(slot):
	return slot.get_child_count() == 0
