extends ClickableControl
class_name EntityContainer

const Direction = EffectResource.Direction

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


func distance_to(plate: EntityContainer):
	var distance = abs(id - plate.id)
	if get_line() != plate.get_line():
		distance += 1
	return distance


func direction_to(plate: EntityContainer) -> Direction:
	# Même case, pas de direction
	if plate == self:
		return Direction.NONE
	var distance = id - plate.id
	# Même colonne
	if distance == 0:
		return Direction.UP if is_melee() else Direction.DOWN
	# Si les cases ne sont pas sur la même ligne et la même colonne, pas de direction
	if get_line() != plate.get_line():
		return Direction.NONE
	# Même ligne
	return Direction.RIGHT if distance < 0 else Direction.LEFT


func get_first_entity(direction_method: Callable, distance: int = 1):
	var next_plate: EntityContainer = direction_method.call()
	if next_plate.is_empty() and distance > 1 and next_plate != self:
		return next_plate.get_first_entity(direction_method, distance - 1)
	return next_plate.get_entity()
	


#region directions
func get_right_plate(distance: int = 1):
	var line = get_line()
	var pi = line.find(self)
	var next_plate: EntityContainer
	if pi == 3:
		next_plate = self
	else:
		next_plate = line[pi + 1]
	if distance > 1:
		return next_plate.get_right_plate(distance - 1)
	return next_plate

func get_left_plate(distance: int = 1):
	var line = get_line()
	var pi = line.find(self)
	var next_plate: EntityContainer
	if pi == 0:
		next_plate = self
	else:
		next_plate = line[pi - 1]
	if distance > 1:
		return next_plate.get_left_plate(distance - 1)
	return next_plate

func get_up_plate(_distance: int = 1):
	if is_distance():
		return self
	var pi = get_line().find(self)
	return get_line(true)[pi]

func get_down_plate(_distance: int = 1):
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
	var left = get_left_plate()
	var right = get_right_plate()
	var result = []
	if left != self:
		result.append(left)
	if right != self:
		result.append(right)
	return result
