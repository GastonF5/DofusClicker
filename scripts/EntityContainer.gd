extends ClickableControl
class_name EntityContainer

const DISTANCE := "Distance"
const MELEE := "Melee"

var id: int

var _entity: Entity

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


func is_distance():
	return get_parent().name == DISTANCE

func is_melee():
	return get_parent().name == MELEE


func get_line(other: bool = false):
	if is_distance():
		if other:
			return MonsterManager.get_melee_plates()
		return MonsterManager.get_distance_plates()
	if is_melee():
		if other:
			return MonsterManager.get_distance_plates()
		return MonsterManager.get_melee_plates()

#region directions
func get_right_plate():
	var line = get_line()
	var pi = line.find(self)
	if pi == 3:
		return self
	return line[pi + 1]

func get_left_plate():
	var line = get_line()
	var pi = line.find(self)
	if pi == 0:
		return self
	return line[pi - 1]

func get_up_plate():
	if is_distance():
		return self
	var pi = get_line().find(self)
	return get_line(true)[pi]

func get_down_plate():
	if is_melee():
		return self
	var pi = get_line().find(self)
	return get_line(true)[pi]
#endregion


func init_entity_texture():
	_entity.global_position += Vector2(0, -32)


func get_entity():
	if get_children().size() == 0:
		return null
	for child in get_children():
		if Entity.is_monster(child):
			return child
	return null


func _on_child_entered_tree(node):
	if is_instance_of(node, Entity):
		_entity = node
		init_entity_texture()
		if selected:
			_entity.select()


func _on_child_exiting_tree(_node):
	_entity = get_entity()


func _on_tree_entered():
	id = name.substr(name.length() - 2) as int


func is_empty():
	return get_entity() == null


func select(container):
	PlayerManager.selected_plate = container


func get_plate_index():
	return get_parent().get_children().find(self)


func get_neighbor_plates():
	var index = get_plate_index()
	var plates = get_parent().get_children()
	var neighbor_plates = []
	if index - 1 >= 0:
		neighbor_plates.append(plates[index - 1])
	if index + 1 <= plates.size() - 1:
		neighbor_plates.append(plates[index + 1])
	return neighbor_plates
