class_name DungeonManager
extends Node


static var dungeon_list = [447]


static func is_dungeon(area_id: int):
	return dungeon_list.has(area_id)
