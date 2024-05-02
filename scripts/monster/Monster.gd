extends Entity
class_name Monster

const taken_damage_scene_path = "res://scenes/taken_damage.tscn"

@export var name_label: Label
@export var texture_rect: TextureRect
@export var hp_bar: HPBar
@export var header_texture: TextureRect

@export var attack_bar: TextureProgressBar
@export var attack_amount: Label
@export var pa_bar: PABar
@export var pm_bar: PMBar

var player_manager: PlayerManager
var inventory: Inventory

var resource: MonsterResource

var attack_timer: Timer

var selected = false

var dying = false
signal dies


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
	inventory = get_tree().current_scene.get_node("%Inventory")
	init_caracteristiques(res.caracteristiques)
	
	name = res.name
	name_label.text = res.name
	init_clickable(self)
	texture_rect.texture = res.texture
	
	init_monster_caracteristiques()
	
	resource = res
	if res.boss:
		header_texture.texture = load("res://assets/ui/icons/boss.png")
	elif res.archimonstre:
		header_texture.texture = load("res://assets/ui/icons/archimonstre.png")
	else:
		header_texture.texture = null
	attack_amount.text = str(res.damage)
	new_attack_timer()
	update_timer()


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


func take_damage(amount: int):
	create_taken_damage(amount)
	hp_bar.current_hp -= amount
	if hp_bar.current_hp <= hp_bar.min_value:
		dying = true
	return amount


func new_attack_timer(time = 0.0):
	var attack_time = get_attack_time() if time == 0.0 else time
	if attack_timer != null:
		attack_timer.timeout.disconnect(attack)
		attack_timer.queue_free()
	attack_timer = Timer.new()
	attack_timer.wait_time = abs(attack_time)
	attack_timer.timeout.connect(attack)
	add_child(attack_timer)
	attack_timer.start()


func update_timer():
	if pm_bar.get_amount() == 0:
		attack_timer.paused = true
	else:
		attack_timer.paused = false
		update_attack_bar()


func get_attack_time():
	var pm = pm_bar.get_amount()
	return null if pm == 0 or pm > 10 else 10 / pm


func update_attack_bar():
	var last_max_value = attack_bar.max_value
	var last_value = attack_bar.value
	attack_bar.max_value = get_attack_time()
	attack_bar.value = (last_value * attack_bar.max_value) / last_max_value
	if float(abs(attack_bar.max_value - attack_bar.value)) > 0:
		new_attack_timer(float(abs(attack_bar.max_value - attack_bar.value)))


func attack():
	var _taken_damage = player_manager.take_damage(resource.damage)
	#console.log_info("%s attaque : %d dégât%s" % [name, taken_damage, "" if taken_damage <= 1 else "s"])
	new_attack_timer()


func die():
	drop()
	hp_bar.value = hp_bar.min_value
	get_parent().remove_child(self)
	dies.emit(resource.xp_gain)
	queue_free()


func drop():
	for item_res in resource.drop:
		if randf_range(0, 100) < item_res.drop_rate:
			inventory.add_item(Item.create(item_res, inventory))


func is_selected():
	return PlayerManager.selected_plate == get_parent()


func create_taken_damage(amount: int):
	var taken_damage: TakenDamage = load(taken_damage_scene_path).instantiate()
	get_parent().add_child(taken_damage)
	taken_damage.init(amount)


func select():
	texture_rect.custom_minimum_size = Vector2(230, 230)


func unselect():
	texture_rect.custom_minimum_size = Vector2(192, 192)


static func is_monster(value: Node):
	return is_instance_of(value, Monster)
