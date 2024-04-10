class_name Monster
extends ClickableControl

static var monsters_res: Array[MonsterResource]

@export var name_label: Label
@export var texture_rect: TextureRect
@export var hp_bar: HPBar
@export var selected_texture: TextureRect
@export var header: TextureRect

var inventory: Inventory
var resource: MonsterResource

var hit_timer: Timer

var dying = false
signal dies


static func instantiate(parent: Control) -> Monster:
	monsters_res = FileLoader.get_monster_resources()
	var random_monster_res: MonsterResource = monsters_res[randi_range(0, monsters_res.size() - 1)]
	var monster = FileLoader.get_packed_scene("monster").instantiate()
	parent.add_child(monster)
	monster.init(random_monster_res)
	return monster


func init(res: MonsterResource):
	inventory = $"/root/Main/PlayerManager".inventory
	name = res.name
	name_label.text = res.name
	init_clickable($"Panel")
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
	new_hit_timer()


func take_damage(amount: int):
	hp_bar.current_hp -= amount
	if hp_bar.current_hp <= hp_bar.min_value:
		dying = true


func new_hit_timer():
	if hit_timer != null:
		hit_timer.timeout.disconnect(hit)
		hit_timer.queue_free()
	hit_timer = Timer.new()
	hit_timer.wait_time = resource.hit_time
	hit_timer.timeout.connect(hit)
	add_child(hit_timer)
	hit_timer.start()
	


func hit():
	$"/root/Main/PlayerManager".take_damage(resource.damage)
	new_hit_timer()


func die():
	for item_res in resource.drop:
		inventory.add_item(Item.create(item_res, inventory))
	hp_bar.value = hp_bar.min_value
	get_parent().remove_child(self)
	dies.emit(resource.xp_gain)
	queue_free()
