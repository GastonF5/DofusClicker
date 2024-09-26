extends Entity
class_name Monster

const INIT_POSITION = Vector2(3.5, -150)

var resource: MonsterResource
var grade: GradeResource
var drops: Array[DropResource]
var spell_to_cast: SpellResource

var timers := {}

@export var bars: EntityBars

var selected = false

func _ready():
	for child in get_children(true):
		if child.name != "Content" and child.get("mouse_filter"):
			child.mouse_filter = MOUSE_FILTER_IGNORE


func _process(_delta):
	spell_to_cast = get_spell_to_cast()
	if spell_to_cast and pa_bar.cval >= spell_to_cast.pa_cost:
		if attack(spell_to_cast):
			pa_bar.cval -= spell_to_cast.pa_cost
			spell_to_cast = null


func _enter_tree():
	position = INIT_POSITION


static func instantiate(monster_res: MonsterResource, parent: Control) -> Monster:
	var monster = FileLoader.get_packed_scene("monster").instantiate()
	parent.add_child(monster)
	parent.move_child(monster, 0)
	monster.init(monster_res)
	return monster


func init(res: MonsterResource = null):
	hp_bar = bars.hp_bar
	pa_bar = bars.pa_bar
	pm_bar = bars.pm_bar
	super()
	grade = res.grades[randi_range(0, res.grades.size() - 1)]
	drops = res.drops.duplicate()
	init_caracteristiques(grade.characteristics)
	
	name = res.name
	if Globals.debug:
		name_label.text = "%s (%d)" % [res.name, res.id]
	else:
		name_label.text = "%s" % res.name
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


# Renvoie true si le monstre a effectivement lancé un sort
func attack(spell: SpellResource) -> bool:
	if !spell:
		return false
	SpellsService.perform_spell(self, PlayerManager.player_entity, spell, grade.grade)
	if spell.cooldown > 0:
		var timer: Timer = SpellsService.create_timer(spell.cooldown, spell.name)
		timers[spell.name] = timer
		timer.timeout.connect(delete_timer.bind(timer))
	return true


func delete_timer(timer: Timer):
	timers.erase(timer)
	timer.queue_free()


func get_spell_to_cast():
	var sorted_spells = spells.duplicate()
	sorted_spells.sort_custom(func(a, b): return a.priority > b.priority)
	for spell in sorted_spells:
		if !timers.has(spell.name):
			return spell


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
			if randf_range(0, 100) < get_chance_drop(_drop.percent_drop[0]):
				var item_res = Datas._resources[_drop.object_id]
				item_res.count = max(_drop.count, 1)
				inventory.add_item(Item.create(item_res))


func get_chance_drop(percent_drop: float):
	return percent_drop * PlayerManager.player_entity.get_prospection() / 100.0


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
