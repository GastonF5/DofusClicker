class_name CustomTabContainer
extends TabContainer


@export var tab_bar: TabBar


func _ready():
	tab_bar.tab_changed.connect(_on_tab_bar_tab_changed)
	current_tab = tab_bar.current_tab


func _on_tab_bar_tab_changed(tab):
	current_tab = tab
