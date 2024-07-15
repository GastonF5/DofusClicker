class_name ClassRole
extends Control


const ROLE_TEXTURE_PATH = "res://assets/classes/roles/role_%d.png"

const class_role_scene = preload('res://scenes/class_peeker/class_role.tscn')

@export var texture_rect: TextureRect
@export var label: Label

static var roles = {
	1: "Entrave",
	2: "Tank",
	3: "Protection",
	4: "Soins",
	5: "Dégâts",
	6: "Vitesse",
	7: "Invocation",
	8: "Amélioration"
}

static func create(role_id: int) -> ClassRole:
	var class_role = class_role_scene.instantiate()
	class_role.texture_rect.texture = load(ROLE_TEXTURE_PATH % role_id)
	class_role.label.text = roles[role_id]
	return class_role
