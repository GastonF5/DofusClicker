extends Entity
class_name Monster

@export var name_label: Label
@export var texture_rect: TextureRect
@export var header_texture: TextureRect

var resource: MonsterResource
var grade: GradeResource
var drops: Array[DropResource]

var selected = false

func _ready():
	for child in get_children(true):
		if child.name != "Content" and child.get("mouse_filter"):
			child.mouse_filter = MOUSE_FILTER_IGNORE


func _process(_delta):
	if !spells.is_empty() and pa_bar.cval >= spells[0].pa_cost:
		pa_bar.cval -= spells[0].pa_cost
		attack()


static func instantiate(parent: Control) -> Monster:
	var random_monster_res: MonsterResource = MonsterManager.monsters_res[randi_range(0, MonsterManager.monsters_res.size() - 1)]
	var monster = FileLoader.get_packed_scene("monster").instantiate()
	parent.add_child(monster)
	parent.move_child(monster, 0)
	monster.init(random_monster_res)
	return monster


func init(res: MonsterResource = null):
	player_manager = get_tree().current_scene.get_node("%PlayerManager")
	inventory = player_manager.inventory
	grade = res.grades[randi_range(0, res.grades.size() - 1)]
	drops = res.drops.duplicate()
	init_caracteristiques(grade.characteristics)
	
	name = res.name
	name_label.text = "%s (%d)" % [res.name, res.id]
	init_clickable(self)
	texture_rect.texture = res.texture
	
	super()
	init_monster_caracteristiques()
	init_spells(res.spells)
	
	resource = res
	if res.boss:
		header_texture.texture = load("res://assets/icons/boss.png")
	elif res.archimonstre:
		header_texture.texture = load("res://assets/icons/archimonstre.png")
	else:
		header_texture.texture = null
	
	attack_callable = attack


func init_monster_caracteristiques():
	# Vitalité
	hp_bar.mval = get_vitalite()
	hp_bar.reset()
	# PM
	pm_bar.mval = get_pm()
	pm_bar.reset()
	# PA
	pa_bar.mval = get_pa()
	pa_bar.reset()


func attack():
	#var _taken_damage = player_manager.take_damage(resource.damage)
	#console.log_info("%s attaque : %d dégât%s" % [name, taken_damage, "" if taken_damage <= 1 else "s"])
	Callable(SpellsService, spells[0].spell_name).call()


func die():
	await drop()
	hp_bar.value = hp_bar.min_value
	get_parent().remove_child(self)
	dies.emit(grade.xp)
	queue_free()


func drop():
	for _drop: DropResource in drops:
		if Datas._resources.keys().has(_drop.object_id):
			if randf_range(0, 100) < _drop.percent_drop[0]:
				var item_res = Datas._resources[_drop.object_id]
				item_res.count = _drop.count
				inventory.add_item(Item.create(item_res, inventory))


func is_selected():
	return PlayerManager.selected_plate == get_parent()


func select():
	texture_rect.custom_minimum_size = Vector2(230, 230)


func unselect():
	texture_rect.custom_minimum_size = Vector2(192, 192)
