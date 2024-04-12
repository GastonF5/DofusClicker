class_name StatsManager
extends Node


@export var stats_container: VBoxContainer
@export var points_label: Label
@export var reset_button: Button
var caracteristiques: Array[Caracteristique] = []

static var points = 0
static var max_points = 0

func _ready():
	for node in stats_container.get_children():
		if Caracteristique.Type.keys().has(node.name.to_upper()):
			caracteristiques.append(node)
			node.consume_point.connect(update_points_label)
	reset_button.button_up.connect(reset_points)
	reset_points()
	$"../PlayerManager".xp_bar.lvl_up.connect(on_lvl_up)


func reset_points():
	points = max_points
	for carac in caracteristiques:
		carac.base_amount = 0
	update_points_label()


func update_points_label():
	points_label.text = str(points)


func on_lvl_up():
	max_points += 5
	points += 5
	update_points_label()
