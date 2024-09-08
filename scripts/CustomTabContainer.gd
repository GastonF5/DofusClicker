class_name CustomTabContainer
extends TabContainer


@export var tab_bar: TabBar

var _tab_before_fight := -1

func _ready():
	tab_bar.tab_changed.connect(_on_tab_bar_tab_changed)
	current_tab = tab_bar.current_tab
	if tab_bar.name == "LeftTabBar":
		GameManager.start_fight.connect(_on_fight_started)
		GameManager.end_fight.connect(_on_fight_ended)


func _on_tab_bar_tab_changed(tab):
	current_tab = tab


func _on_tab_bar_active_tab_rearranged(idx_to):
	move_child(get_child(current_tab), idx_to)


func _on_fight_started():
	tab_bar.visible = false
	_tab_before_fight = tab_bar.current_tab
	tab_bar.current_tab = 2


func _on_fight_ended():
	tab_bar.visible = true
	tab_bar.current_tab = _tab_before_fight
