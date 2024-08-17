class_name EquipmentContainer
extends SlotContainer

@export var equip_slots: GridContainer

func _ready():
	slot_group_name = "equipment_slot"
	super()


func get_weapon() -> ItemResource:
	var weapon_slot = equip_slots.get_children().filter(func(s): return s.name == "ArmeSlot")[0]
	if weapon_slot.get_child_count() < 2:
		return null
	return weapon_slot.get_child(1).resource


func get_save() -> Dictionary:
	var data = {}
	for slot in equip_slots.get_children():
		var item = null
		if slot.get_child_count() > 1:
			item = slot.get_child(1)
		if item:
			data[slot.name] = item.get_save()
	return data


func load_save(data):
	remove_items()
	for slot_name in data.keys():
		var item_res = SaveManager.get_item_or_resource(data[slot_name]["id"])
		if item_res:
			item_res.load_save(data[slot_name])
			equip_slots.get_node(slot_name).add_child(Item.create(item_res))


func remove_items():
	for slot in equip_slots.get_children():
		for i in range(1, slot.get_child_count()):
			var item = slot.get_child(i)
			slot.remove_child(item)
			item.queue_free()


func set_dragged_entering_drop_parent(slot):
	if dragged:
		if !dragged.is_item()\
		or (dragged.equip_res and dragged.level <= Globals.xp_bar.cur_lvl):
			super(slot)
