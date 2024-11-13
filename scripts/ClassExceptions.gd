class_name ClassExceptions
extends Node


static func is_balise_tactique(entity: Entity):
	return Monster.is_monster(entity) and entity.is_ally and entity.is_invocation and entity.resource.id == 5908
