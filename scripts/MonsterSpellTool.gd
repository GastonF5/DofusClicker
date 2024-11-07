class_name MonsterSpellTool
extends Control


var monster_id: int
var error_label: Label

const ERROR_MESSAGE := "L'id n'existe pas"


func _on_monster_id_line_edit_text_changed(new_text):
	monster_id = new_text.to_int()
	$%SearchButton.disabled = new_text != str(monster_id)


func _on_search_button_pressed():
	clear_error()
	clear_spells()
	$%SearchButton.disabled = true
	var url = API.API_SUFFIX + "monsters/%d?$select[]=spells" % monster_id
	var request = await API.request(url)
	await API.await_for_request_completed(request)
	var json = API.get_data(url)
	if !json:
		create_error()
		return
	for spell_id in json["spells"]:
		spell_id = int(spell_id)
		var spell_url = API.API_SUFFIX + "spells/%d" % spell_id
		await API.await_for_request_completed(await API.request(spell_url))
		create_spell(API.get_data(spell_url))


func create_spell(data):
	var vbc = VBoxContainer.new()
	$%SpellsContainer.add_child(vbc)
	
	var spell_url: String = data["img"]
	
	var texture_rect := TextureRect.new()
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var error = await API.await_for_request_completed(await API.request(spell_url))
	var spell_texture = API.get_texture(spell_url)
	texture_rect.texture = spell_texture
	FileSaver.save_monster_spell_asset(spell_texture, spell_url.split("/")[-1].split(".")[0])
	vbc.add_child(texture_rect)
	
	create_line("id", str(data["id"]), vbc)
	create_line("name", data["name"]["fr"], vbc)
	create_line("url", spell_url, vbc)


func clear_spells():
	for child in $%SpellsContainer.get_children():
		child.queue_free()


func create_line(line_name: String, data: String, parent: Node):
	var hbc = HBoxContainer.new()
	hbc.custom_minimum_size = Vector2(500, 0)
	parent.add_child(hbc)
	
	var label = Label.new()
	label.text = line_name
	hbc.add_child(label)
	
	var line_edit = LineEdit.new()
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_edit.text = data
	hbc.add_child(line_edit)


func create_error():
	error_label = Label.new()
	error_label.name = "ErrorLabel"
	error_label.text = ERROR_MESSAGE
	error_label.add_theme_color_override("font_color", Color.RED)
	$%MonsterSearch.add_child(error_label)


func clear_error():
	if error_label:
		$%MonsterSearch.remove_child($%MonsterSearch.get_node("ErrorLabel"))
		error_label = null
