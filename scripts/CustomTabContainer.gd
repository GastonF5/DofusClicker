class_name CustomTabContainer
extends TabContainer


@export var tab_bar: TabBar

func _ready():
	tab_bar.tab_changed.connect(_on_tab_bar_tab_changed)
	current_tab = tab_bar.current_tab
	if tab_bar.name == "LeftTabBar":
		GameManager.start_fight.connect(_on_fight_started)
		GameManager.end_fight.connect(_on_fight_ended)
	if tab_bar.name == "JobTabBar":
		tab_bar.set_tab_title(current_tab, get_current_tab_control().name.trim_suffix("Panel"))


func _on_tab_bar_tab_changed(tab):
	current_tab = tab
	if tab_bar.name == "JobTabBar":
		for i in range(tab_bar.tab_count):
			tab_bar.set_tab_title(i, "")
		tab_bar.set_tab_title(tab, get_current_tab_control().name.trim_suffix("Panel"))


func _on_tab_bar_active_tab_rearranged(idx_to):
	move_child(get_child(current_tab), idx_to)


func _on_fight_started():
	tab_bar.visible = false
	tab_bar.current_tab = 2


func _on_fight_ended():
	tab_bar.visible = true
