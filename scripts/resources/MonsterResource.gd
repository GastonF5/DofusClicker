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
			if Globals.debug:
				log.info("Request for %s" % image_url)
				await API.await_for_request_completed(await API.request(image_url))
				texture = API.get_texture(image_url)
			else:
				log.error("Failed to load monster texture (id: %d)" % id)


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
		do_override_drops()
		do_override_areas()
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
			do_override_drops(res_to_override)
			res_to_override.drops.assign(drops)
			do_override_drops()
		if !areas.is_empty():
			do_override_areas(res_to_override)
			res_to_override.areas.assign(areas)
			do_override_areas()
		Datas._monsters[id] = res_to_override
	log.info("Override done for \"%s\"" % resource_file_name)


func do_override_drops(res_to_override: MonsterResource = null):
	if res_to_override:
		for drop: DropResource in res_to_override.drops:
			var data: ItemResource = Datas.get_item_res(drop.object_id)
			if data:
				data.drop_monster_ids.erase(id)
				Datas.set_item_res(drop.object_id, data, data.get_data_type())
	else:
		for drop: DropResource in drops:
			var data: ItemResource = Datas.get_item_res(drop.object_id)
			if data:
				data.drop_monster_ids.append(id)
				Datas.set_item_res(drop.object_id, data, data.get_data_type())


func do_override_areas(res_to_override: MonsterResource = null):
	if res_to_override:
		for area_id: int in res_to_override.areas:
			if Datas._subareas.has(area_id):
				var data = Datas._subareas[area_id]
				data._monster_ids.erase(id)
				Datas._subareas[area_id] = data
	else:
		for area_id: int in areas:
			if Datas._subareas.has(area_id):
				var data = Datas._subareas[area_id]
				data._monster_ids.append(id)
				Datas._subareas[area_id] = data
