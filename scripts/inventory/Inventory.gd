class_name Inventory
extends Control


static var slots = []

signal item_entered_tree
signal item_exiting_tree


func _ready():
	for slot in get_children():
		slots.append(slot)
		connect_slot_signals(slot)


func get_item(slot) -> Item:
	if slot.get_children().is_empty():
		return null
	return slot.get_child(0) as Item


func get_slot(item):
	var items_in_inventory = slots.map(func(s): return null if s.get_children().size() != 1 else s.get_child(0)).filter(func(i): return i != null and Item.equals(item, i))
	if items_in_inventory.size() > 1:
		push_error("Plus d'un slot a été trouvé")
		return null
	return null if items_in_inventory.size() == 0 else items_in_inventory[0].get_parent()


func add_item(item: Item, _slot: Button = null):
	if check_equipment_slot(item, _slot):
		add_item(item)
		return
	var item_in_slot: Item
	if _slot != null:
		item_in_slot = get_item(_slot)
		if item_in_slot == null:
			_slot.add_child(item)
			item_entered_tree.emit(get_items())
			return
		if Item.equals(item, item_in_slot):
			item_in_slot.count += 1
		else:
			item_in_slot.drop_parent = item.old_parent
			item_in_slot.drag()
			item_in_slot.drop()
			_slot.add_child(item)
			item_entered_tree.emit(get_items())
	else:
		for slot in slots:
			item_in_slot = get_item(slot)
			if item_in_slot == null:
				slot.add_child(item)
				item_entered_tree.emit(get_items())
				item.drop_parent = slot
				break
			if Item.equals(item, item_in_slot):
				item_in_slot.count += 1
				item_entered_tree.emit(get_items())
				return
		# si l'item n'a pas été ajouté, on étend l'inventaire et on rappelle la fonction pour ajouter l'item
		if item.get_parent() == null:
			expand()
			add_item(item)


func remove_items(items: Array):
	for item in items:
		var item_in_inventory = get_slot(item).get_child(0)
		if item_in_inventory.count <= item.count:
			item_in_inventory.get_parent().remove_child(item_in_inventory)
			item_in_inventory.queue_free()
		else:
			item_in_inventory.count -= item.count


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
		if EquipmentManager.is_equip_slot(dragged_item.old_parent):
			dragged_item.drop_parent = Inventory.slots[0]
		else:
			dragged_item.drop_parent = dragged_item.old_parent


func expand():
	var slot_scene = load("res://scenes/inventory/inventory_slot.tscn")
	for i in range(4):
		var slot = slot_scene.instantiate()
		slots.append(slot)
		add_child(slot)


func get_items():
	var items = slots.duplicate()
	items = items.map(func(s): return null if s.get_children().size() != 1 else s.get_child(0) as Item).filter(func(i): return i != null)
	return items.map(func(item): return item as Item)


func _on_item_exiting_slot(item):
	var items = get_items()
	items.erase(item)
	item_exiting_tree.emit(get_items())


func connect_slot_signals(slot):
	slot.mouse_entered.connect(_on_mouse_entered_slot.bind(slot))
	slot.mouse_exited.connect(_on_mouse_exited_slot)
	slot.child_exiting_tree.connect(_on_item_exiting_slot)
