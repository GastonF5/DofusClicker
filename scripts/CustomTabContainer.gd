class_name CustomTabContainer
extends TabContainer


@export var tab_bar: TabBar


func _ready():
	tab_bar.tab_changed.connect(_on_tab_bar_tab_changed)


func _on_tab_bar_tab_changed(tab):
	current_tab = tab
