extends AbstractManager

var scripters: Array[Scripter]


func initialize():
	add_script(5)
	super()


func reset():
	super()


func add_script(nb_scripters := 1):
	for i in range(nb_scripters):
		var new_script = Scripter.create()
		scripters.append(new_script)
		new_script.priority_changed.connect(sort_scripters)


func _process(_delta):
	if !scripters.is_empty() and GameManager.in_fight:
		var scripter = find_scripter()
		if scripter:
			scripter.do_action()


func find_scripter() -> Scripter:
	for scripter in scripters:
		if scripter.can_do_action():
			return scripter
	return null


func sort_scripters() -> void:
	scripters.sort_custom(
		func(s1, s2):
			return s1.get_priority() >= s2.get_priority()
	)
