class_name DraggableControl
extends Control


var old_parent
var drop_parent
var draggable := false
var dragged := false:
	set(value):
		dragged = value
		if value:
			z_index = 10
			if is_item(): PlayerManager.dragged_item = self
			if is_spell(): PlayerManager.dragged_spell = self
		else:
			z_index = 0
			if is_item(): PlayerManager.dragged_item = null
			if is_spell(): PlayerManager.dragged_spell = null

var initialized := false


func _enter_tree():
	if old_parent is Button:
		old_parent.button_pressed = false
	if !initialized and draggable:
		init_draggable()
		initialized = true


func init_draggable():
	if get_parent() != null:
		get_parent().button_down.connect(_on_button_down)
	drop_parent = get_parent()


func _process(_delta):
	if dragged:
		global_position = get_global_mouse_position() - size / 2


func _input(event):
	if dragged:
		if event.is_action_released("LMB") and !get_parent().is_in_group("slot"):# and (!is_spell() or !GameManager.in_fight:
			drop()


func _on_button_down():
	if draggable:
		if !is_spell() or !GameManager.in_fight:
			drag()


func drag():
	dragged = true
	old_parent = get_parent()
	if get_parent() != null:
		get_parent().remove_child(self)
		Globals.over_ui.add_child(self)


func drop():
	dragged = false
	# Si le slot est un slot d'équipement et qu'il est déjà occupé, on échange les items
	var drop_is_equip = drop_parent.is_in_group("equipment_slot")
	var drop_is_inventory = drop_parent.is_in_group("inventory_slot")
	if drop_is_equip and !Globals.equipment_container.slot_is_empty(drop_parent):
		swap(Globals.equipment_container.get_item(drop_parent))
	var inventory_slot_empty = drop_is_equip and drop_parent.get_child_count() != 1 and !drop_parent.get_child(1).is_equipment()
	var equip_slot_empty = drop_is_inventory and drop_parent.get_child_count() != 0 and !drop_parent.get_child(0).is_equipment()
	if old_parent.is_in_group("equipment_slot") and (inventory_slot_empty or equip_slot_empty):
		drop_parent = old_parent
	# On ne peut pas équiper un item dont on n'a pas le niveau
	if drop_parent != old_parent and is_equipment() and self.resource.level > Globals.xp_bar.cur_lvl:
		Globals.console.log_error("Vous n'avez pas le niveau pour équiper cet objet.")
		drop_parent = old_parent
	change_parent()
	position = Vector2.ZERO


func change_parent():
	if old_parent.button_down.is_connected(_on_button_down):
		old_parent.button_down.disconnect(_on_button_down)
	get_parent().remove_child(self)
	if is_node_droppable(drop_parent):
		swap(drop_parent.get_child(0))
	old_parent = null
	drop_parent.button_down.connect(_on_button_down)


func is_node_droppable(node: Node):
	var is_inventory_slot = node.is_in_group("inventory_slot")
	var is_spell_slot = node.is_in_group("spell_slot")
	var is_empty = node.get_child_count() == 1
	return is_empty and ((is_inventory_slot and is_item()) or (is_spell_slot and is_spell()))


func is_item():
	return self is Item


func is_spell():
	return self is Spell


func is_equipment():
	return is_item() and self.resource.equip_res


func swap(to_swap: DraggableControl):
	to_swap.drop_parent = old_parent
	to_swap.old_parent = drop_parent
	to_swap.change_parent()
