class_name EquipmentContainer
extends SlotContainer

@export var equip_slots: GridContainer

func _ready():
	slot_group_name = "equipment_slot"
	super()


func get_weapon_resource():
	var weapon_slot = equip_slots.get_children().filter(func(s): return s.name == "ArmeSlot")[0]
	if weapon_slot.get_child_count() < 2:
		return null
	return weapon_slot.get_child(1).resource.equip_res
