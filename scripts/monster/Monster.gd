extends Entity
class_name Monster

@export var name_label: Label
@export var texture_rect: TextureRect
@export var header_texture: TextureRect

@export var attack_amount: Label

var resource: MonsterResource
var grade: GradeResource
var drops: Array[DropResource]

var selected = false

var are_drops_initialized = false
signal drops_initialized

func _ready():
	for child in get_children(true):
		if child.name != "Content" and child.get("mouse_filter"):
			child.mouse_filter = MOUSE_FILTER_IGNORE


func _process(_delta):
	attack_bar.value = float(attack_bar.max_value - attack_timer.time_left)


static func instantiate(parent: Control) -> Monster:
	var random_monster_res: MonsterResource = MonsterManager.monsters_res[randi_range(0, MonsterManager.monsters_res.size() - 1)]
	var monster = FileLoader.get_packed_scene("monster").instantiate()
	parent.add_child(monster)
	parent.move_child(monster, 0)
	monster.init(random_monster_res)
	return monster


func init(res: MonsterResource):
	player_manager = get_tree().current_scene.get_node("%PlayerManager")
	inventory = player_manager.inventory
	grade = res.grades[randi_range(0, res.grades.size() - 1)]
	drops = res.drops.duplicate()
	init_caracteristiques(grade.characteristics)
	
	name = res.name
	name_label.text = res.name
	init_clickable(self)
	texture_rect.texture = res.texture
	
	init_monster_caracteristiques()
	
	resource = res
	if res.boss:
		header_texture.texture = load("res://assets/icons/boss.png")
	elif res.archimonstre:
		header_texture.texture = load("res://assets/icons/archimonstre.png")
	else:
		header_texture.texture = null
	attack_amount.text = str(res.damage)
	attack_callable = attack
	new_attack_timer()
	update_timer()
	
	init_drops()


func init_monster_caracteristiques():
	# Vitalité
	hp_bar.init(get_vitalite())
	connect_to_stat(Caracteristique.Type.VITALITE, hp_bar.update, [get_vitalite, get_vitalite])
	# PM
	pm_bar.init(get_pm())
	connect_to_stat(Caracteristique.Type.PM, pm_bar.change_max_pm, [get_pm, true])
	connect_to_stat(Caracteristique.Type.PM, update_timer, [])
	# PA
	pa_bar.init(get_pa())
	connect_to_stat(Caracteristique.Type.PA, pa_bar.update, [get_pa, true])


func attack():
	var _taken_damage = player_manager.take_damage(resource.damage)
	#console.log_info("%s attaque : %d dégât%s" % [name, taken_damage, "" if taken_damage <= 1 else "s"])
	new_attack_timer()


func die():
	await drop()
	hp_bar.value = hp_bar.min_value
	get_parent().remove_child(self)
	dies.emit(grade.xp)
	queue_free()


func drop():
	if !are_drops_initialized:
		await drops_initialized
	for _drop: DropResource in drops:
		if _drop.object and randf_range(0, 100) < _drop.object.drop_rate:
			inventory.add_item(Item.create(_drop.object, inventory))


func init_drops():
	are_drops_initialized = false
	var api: API = get_tree().current_scene.get_node("API")
	var composite_signal = API.CompositeSignal.new()
	var drop_ids = resource.drops.map(func(d): return d.object_id)
	for id in drop_ids:
		composite_signal.add_method(api.request_item_by_id.bind(id))
	await composite_signal.finished
	var objects = drop_ids.map(func(id): return api.get_data(id))
	for _drop: DropResource in drops:
		var matching_object = objects.filter(func(o): return o.id == _drop.object_id)
		_drop.object = null if matching_object.size() == 0 else matching_object[0]
		if _drop.object:
			_drop.object.drop_rate = _drop.percent_drop
	are_drops_initialized = true
	drops_initialized.emit()


func is_selected():
	return PlayerManager.selected_plate == get_parent()


func select():
	texture_rect.custom_minimum_size = Vector2(230, 230)


func unselect():
	texture_rect.custom_minimum_size = Vector2(192, 192)


static func is_monster(value: Node):
	return is_instance_of(value, Monster)
