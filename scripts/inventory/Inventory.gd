class_name Inventory
extends SlotContainer


func _ready():
	slot_group_name = "inventory_slot"
	super()


func connect_slot_signals(slot):
	super(slot)
	slot.child_exiting_tree.connect(_on_item_exiting_slot)


func get_item(slot) -> Item:
	if slot.get_children().is_empty():
		return null
	return slot.get_child(0) as Item


func get_slot(item):
	var items_in_inventory = slots.map(func(s):
		if s.get_children().size() != 1:
			return null
		return s.get_child(0)).filter(func(i): return i and Item.equals(item, i))
	if items_in_inventory.size() > 1:
		console.log_error("Plus d'un slot a été trouvé")
		return null
	return null if items_in_inventory.size() == 0 else items_in_inventory[0].get_parent()


func add_item(item: Item, _slot: Button = null):
	if check_equipment_slot(item, _slot):
		add_item(item)
		return
	var item_in_slot: Item
	if _slot:
		item_in_slot = get_item(_slot)
		if !item_in_slot:
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
			if !item_in_slot:
				slot.add_child(item)
				item_entered_tree.emit(get_items())
				item.drop_parent = slot
				break
			if Item.equals(item, item_in_slot):
				item_in_slot.count += 1
				item_entered_tree.emit(get_items())
				return
		# si l'item n'a pas été ajouté, on étend l'inventaire et on rappelle la fonction pour ajouter l'item
		if !item.get_parent():
			expand()
			add_item(item)


func remove_items(items: Array):
	for item in items:
		var slot = get_slot(item)
		if slot:
			var item_in_inventory = slot.get_child(0)
			if item_in_inventory.count <= item.count:
				item_in_inventory.get_parent().remove_child(item_in_inventory)
				item_in_inventory.queue_free()
			else:
				item_in_inventory.count -= item.count


func check_equipment_slot(item: DraggableControl, slot) -> bool:
	var old_parent_is_equip_slot = item.old_parent and item.old_parent.is_in_group("equipment_slot")
	var drop_parent_is_equip_slot = item.drop_parent and item.drop_parent.is_in_group("equipment_slot")
	return slot and old_parent_is_equip_slot and !drop_parent_is_equip_slot


func set_dragged_entering_drop_parent(slot):
	dragged = PlayerManager.dragged_item
	super(slot)


func set_dragged_exited_drop_parent():
	dragged = PlayerManager.dragged_item
	super()


func expand():
	var slot_scene = FileLoader.get_packed_scene("inventory/inventory_slot")
	for i in range(4):
		var slot = slot_scene.instantiate()
		slots.append(slot)
		add_child(slot)


func get_items():
	var items = slots.duplicate()
	items = items.map(func(s):
		if s.get_children().size() != 1:
			return null
		return s.get_child(0) as Item).filter(func(i): return i != null)
	return items.map(func(item): return item as Item)


func _on_item_exiting_slot(item):
	var items = get_items()
	items.erase(item)
	item_exiting_tree.emit(get_items())
