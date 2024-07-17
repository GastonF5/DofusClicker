extends Entity
class_name Monster

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


static func instantiate(monster_res: MonsterResource, parent: Control) -> Monster:
	var monster = FileLoader.get_packed_scene("monster").instantiate()
	parent.add_child(monster)
	parent.move_child(monster, 0)
	monster.init(false, monster_res)
	return monster


func init(is_player := false, res: MonsterResource = null):
	super()
	player = is_player
	inventory = player_manager.inventory
	grade = res.grades[randi_range(0, res.grades.size() - 1)]
	drops = res.drops.duplicate()
	init_caracteristiques(grade.characteristics)
	
	name = res.name
	name_label.text = "%s (%d)" % [res.name, res.id]
	init_clickable(self)
	texture_rect.texture = res.texture
	
	init_bars()
	init_spells(res.spells)
	
	resource = res
	if res.boss:
		header_texture.texture = load("res://assets/icons/boss.png")
	elif res.archimonstre:
		header_texture.texture = load("res://assets/icons/archimonstre.png")
	else:
		header_texture.texture = null
	
	attack_callable = attack


func init_bars():
	# Vitalité
	hp_bar.mval = get_vitalite()
	hp_bar.reset()
	# PM
	pm_bar.mval = get_pm()
	pm_bar.reset()
	# PA
	pa_bar.mval = get_pa()
	pa_bar.cval = 0
	super()


func attack():
	var spell_to_cast = spells[0]
	var grade := 0
	SpellsService.perform_spell(self, PlayerManager.player_entity, spell_to_cast, grade)


func die():
	super()
	await drop()
	hp_bar.value = hp_bar.min_value
	if get_parent():
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


func _on_texture_container_mouse_entered():
	show_description()


func _on_texture_container_mouse_exited():
	hide_description()
