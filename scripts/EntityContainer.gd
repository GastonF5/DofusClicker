extends ClickableControl
class_name EntityContainer


var id: int

var monster: Monster

var selected: bool:
	set(value):
		var entity = get_entity()
		selected = value
		if selected:
			self_modulate = Color.ORANGE_RED
			if entity:
				entity.select()
		else:
			self_modulate = Color.WHITE
			if entity:
				entity.unselect()


func _ready():
	init_clickable(self)
	clicked.connect(select)


func init_monster_texture():
	monster.global_position += Vector2(0, -32)


func get_entity():
	if get_children().size() == 0:
		return null
	for child in get_children():
		if Monster.is_monster(child):
			return child
	return null


func _on_child_entered_tree(node):
	if is_instance_of(node, Monster):
		monster = node
		init_monster_texture()
		if selected:
			monster.select()


func _on_child_exiting_tree(_node):
	monster = get_entity()


func _on_tree_entered():
	id = name.substr(name.length() - 2) as int


func is_empty():
	return get_child_count() == 0 or !get_children().any(Monster.is_monster)


func select(container):
	PlayerManager.selected_plate = container
