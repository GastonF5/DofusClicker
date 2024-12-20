class_name Filter
extends Control


static var scene = preload("res://scenes/filters/filter.tscn")

static func create(carac: String, callable: Callable, parent: Node) -> Filter:
	var nfilter = Filter.scene.instantiate()
	nfilter.texture_rect.texture = FileLoader.get_stat_asset(carac)
	nfilter.carac_label.text = StatResource.get_type_label(carac)
	nfilter.connect_to_checkbox(callable.bind(carac))
	parent.add_child(nfilter)
	return nfilter


@export var texture_rect: TextureRect
@export var carac_label: Label
@export var checkbox: CheckBox


func connect_to_checkbox(callable: Callable):
	checkbox.toggled.connect(callable)
