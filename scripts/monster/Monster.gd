class_name Monster
extends ClickableControl

static var monsters_res: Array[MonsterResource]

@export var name_label: Label
@export var texture_rect: TextureRect
@export var hp_bar: HPBar
@export var selected_texture: TextureRect
@export var header: TextureRect

@export var attack_bar: ProgressBar
@export var attack_amount: Label

@onready var inventory: Inventory = $"/root/Main/PlayerManager".inventory
var resource: MonsterResource

var attack_timer: Timer

var dying = false
signal dies


func _process(_delta):
	if attack_timer != null:
		attack_bar.value = attack_bar.max_value - attack_timer.time_left


static func instantiate(parent: Control) -> Monster:
	monsters_res = FileLoader.get_monster_resources()
	var random_monster_res: MonsterResource = monsters_res[randi_range(0, monsters_res.size() - 1)]
	var monster = FileLoader.get_packed_scene("monster").instantiate()
	parent.add_child(monster)
	monster.init(random_monster_res)
	return monster


func init(res: MonsterResource):
	name = res.name
	name_label.text = res.name
	init_clickable($"VBC/Content")
	selected_texture.visible = false
	texture_rect.texture = res.texture
	hp_bar.init(res.max_health)
	resource = res
	if res.boss:
		header.texture = load("res://assets/ui/icons/boss.png")
	elif res.archimonstre:
		header.texture = load("res://assets/ui/icons/archimonstre.png")
	else:
		header.texture = null
	attack_amount.text = str(res.damage)
	attack_bar.max_value = res.attack_time
	new_attack_timer()


func take_damage(amount: int):
	hp_bar.current_hp -= amount
	if hp_bar.current_hp <= hp_bar.min_value:
		dying = true


func new_attack_timer():
	if attack_timer != null:
		attack_timer.timeout.disconnect(attack)
		attack_timer.queue_free()
	attack_timer = Timer.new()
	attack_timer.wait_time = resource.attack_time
	attack_timer.timeout.connect(attack)
	add_child(attack_timer)
	attack_timer.start()
	


func attack():
	$"/root/Main/PlayerManager".take_damage(resource.damage)
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
