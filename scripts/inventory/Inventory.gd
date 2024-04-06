class_name Inventory
extends Control


static var slots = []


func _ready():
	for slot in get_children():
		slots.append(slot)
		slot.mouse_entered.connect(_on_mouse_entered_slot.bind(slot))
		slot.mouse_exited.connect(_on_mouse_exited_slot)


static func get_item(slot) -> Item:
	if slot.get_children().is_empty():
		return null
	return slot.get_child(0) as Item


static func add_item(item: Item, _slot: Button):
	if _slot != null:
		var item_in_slot: Item = get_item(_slot)
		if item_in_slot == null:
			_slot.add_child(item)
			return
		if item_in_slot.name == item.name:
			item_in_slot.count += 1
		else:
			item_in_slot.drop_parent = item.old_parent
			item_in_slot.drag()
			item_in_slot.drop()
			_slot.add_child(item)
	else:
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
		dragged_item.drop_parent = slot


func _on_mouse_exited_slot():
	var dragged_item = GameManager.dragged_item
	if dragged_item != null:
		dragged_item.drop_parent = dragged_item.old_parent
