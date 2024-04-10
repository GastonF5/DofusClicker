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


func add_item(item: Item, _slot: Button = null):
	if check_equipment_slot(item, _slot):
		add_item(item)
		return
	var item_in_slot: Item
	if _slot != null:
		item_in_slot = get_item(_slot)
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
			item_in_slot = get_item(slot)
			if item_in_slot == null:
				slot.add_child(item)
				break
			if item_in_slot.name == item.name:
				item_in_slot.count += 1
				return
		# si l'item n'a pas été ajouté, on étend l'inventaire et on rappelle la fonction pour ajouter l'item
		if item.get_parent() == null:
			expand()
			add_item(item)


func check_equipment_slot(item: DraggableControl, slot) -> bool:
	var old_parent_is_equip_slot = item.old_parent != null and item.old_parent.is_in_group("equipment_slot")
	var drop_parent_is_equip_slot = item.drop_parent != null and item.drop_parent.is_in_group("equipment_slot")
	return slot != null and old_parent_is_equip_slot and !drop_parent_is_equip_slot


static func _on_mouse_entered_slot(slot):
	var dragged_item = PlayerManager.dragged_item
	if dragged_item != null:
		dragged_item.drop_parent = slot


static func _on_mouse_exited_slot():
	var dragged_item = PlayerManager.dragged_item
	if dragged_item != null:
		dragged_item.drop_parent = dragged_item.old_parent


func expand():
	var slot_scene = load("res://scenes/inventory/inventory_slot.tscn")
	for i in range(4):
		var slot = slot_scene.instantiate()
		slots.append(slot)
		add_child(slot)
