extends TextureRect
class_name MonsterContainer


var id: int

var monster: Monster:
	set(value):
		monster = value
		if monster != null:
			init_monster_texture()


func init_monster_texture():
	monster.global_position += Vector2(0, -32)


func _on_child_entered_tree(node):
	if is_instance_of(node, Monster):
		monster = node
		move_child(node, 0)


func _on_child_exiting_tree(_node):
	monster = null


func _on_tree_entered():
	id = name.substr(name.length() - 2) as int


func is_empty():
	return get_child_count() == 0 or !get_children().any(func(child): return is_instance_of(child, Monster))
