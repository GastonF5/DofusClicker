class_name MonsterResource
extends ThreadedLoadingTexture

const black_list = [494]

@export var id: int
@export var name: String
@export var race_id: int
@export var race: String

@export var image_url: String

@export var boss: bool
@export var archimonstre: bool
@export var corresponding_archimonstre_id: int
@export var corresponding_non_archimonstre_id: int

@export var grades: Array[GradeResource]

@export var spells: Array[int]
@export var drops: Array[DropResource]

@export var areas: Array[int]

var node_texture: TextureRect

func get_id():
	return id

func load_texture():
	if !texture:
		var success = _load("monsters/images/", id)
		if !success:
			await API.await_for_request_completed(await API.request(image_url))
			texture = API.get_texture(image_url)
			FileSaver.save_monster_asset(texture, id)


func black_listed():
	return black_list.has(id)


func get_areas():
	var available_areas = []
	for area_id in areas:
		if Datas._subareas.has(area_id):
			if Datas._subareas[area_id].white_listed():
				available_areas.append(Datas._subareas[area_id])
	return available_areas


static func is_protecteur(monster: MonsterResource):
	return monster.race.begins_with("Protecteur")


func do_override(resource_file_name: String):
	if id == 0:
		log.info("No id on MonsterResource \"%s\" : skipped override" % resource_file_name)
		return
	if !Datas._monsters.has(id):
		Datas._monsters[id] = self
	else:
		var res_to_override: MonsterResource = Datas._monsters[id]
		if name != "":
			res_to_override.name = name
		if race_id != 0:
			res_to_override.race_id = race_id
		if race != "":
			res_to_override.race = race
		if image_url != "":
			res_to_override.image_url = image_url
		if boss:
			res_to_override.boss = boss
		if archimonstre:
			res_to_override.archimonstre = archimonstre
		if corresponding_archimonstre_id != 0:
			res_to_override.corresponding_archimonstre_id = corresponding_archimonstre_id
		if corresponding_non_archimonstre_id != 0:
			res_to_override.corresponding_non_archimonstre_id = corresponding_non_archimonstre_id
		if !grades.is_empty():
			res_to_override.grades.assign(grades)
		if !spells.is_empty():
			res_to_override.spells.assign(spells)
		if !drops.is_empty():
			for drop: DropResource in res_to_override.drops:
				if Datas._resources.has(drop.object_id):
					Datas._resources[drop.object_id].drop_monster_ids.erase(id)
			res_to_override.drops.assign(drops)
			for drop: DropResource in drops:
				Datas._resources[drop.object_id].drop_monster_ids.append(id)
		if !areas.is_empty():
			for area_id: int in res_to_override.areas:
				if Datas._resources.has(area_id):
					Datas._subareas[area_id]._monster_ids.erase(id)
			res_to_override.areas.assign(areas)
			for area_id: int in areas:
				Datas._subareas[area_id]._monster_ids.append(id)
		Datas._monsters[id] = res_to_override
	log.info("Override done for \"%s\"" % resource_file_name)
