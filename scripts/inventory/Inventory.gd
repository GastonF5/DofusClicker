class_name Inventory
extends SlotContainer


var slot_under_mouse: Node


func _ready():
	slot_group_name = "inventory_slot"
	super()


func _input(event):
	if slot_under_mouse and get_item(slot_under_mouse) and event.is_action_released("RMB"):
		SupprimerButton.create(Globals.over_ui, slot_under_mouse.global_position, get_item(slot_under_mouse))


func connect_slot_signals(slot):
	super(slot)
	slot.child_exiting_tree.connect(_on_item_exiting_slot)
	slot.mouse_entered.connect(_on_mouse_enter_slot.bind(slot))
	slot.mouse_exited.connect(_on_mouse_exit_slot)


func _on_mouse_enter_slot(slot):
	slot_under_mouse = slot

func _on_mouse_exit_slot():
	slot_under_mouse = null


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
	var item_in_slot: Item
	if _slot:
		item_in_slot = get_item(_slot)
		if !item_in_slot:
			_slot.add_child(item)
			item_entered_tree.emit()
			return
		if Item.equals(item, item_in_slot):
			item_in_slot.count += 1
		else:
			item_in_slot.swap(item)
			item_entered_tree.emit()
	else:
		var existing_item_slot = get_slot(item)
		if existing_item_slot:
			get_item(existing_item_slot).count += 1
		else:
			add_item(item, get_first_empty_slot())
		item_entered_tree.emit()


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


func _on_item_exiting_slot(item):
	if !Globals.quitting:
		var items = get_items()
		items.erase(item)
		item_exiting_tree.emit()


func get_first_empty_slot():
	var empty_slots = get_empty_slots()
	if empty_slots.is_empty():
		expand()
		return get_first_empty_slot()
	return get_empty_slots()[0]
