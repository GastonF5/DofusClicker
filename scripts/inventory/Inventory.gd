class_name Inventory
extends Control


var slots = []


func _ready():
	for slot in get_children():
		slots.append(slot)
		slot.mouse_entered.connect(_on_mouse_entered_slot.bind(slot))
		slot.mouse_exited.connect(_on_mouse_exited_slot)


func get_item(slot) -> Item:
	if slot.get_children().is_empty():
		return null
	return slot.get_child(0) as Item


func add_item(item: Item):
	for slot in slots:
		var item_in_slot: Item = get_item(slot)
		if item_in_slot == null:
			slot.add_child(item)
			break
		if item_in_slot.name == item.name:
			item_in_slot.count += 1
			break

func _on_mouse_entered_slot(slot):
	var dragged_item = GameManager.dragged_item
	if dragged_item != null:
		dragged_item.parent = slot


func _on_mouse_exited_slot():
	var dragged_item = GameManager.dragged_item
	if dragged_item != null:
		dragged_item.parent = dragged_item.get_parent()
