extends AbstractManager

var scripters:
	get:
		var scripter_container = Globals.get_scripter_container()
		if scripter_container:
			return scripter_container.get_children().map(
				func(e):
					if e is OrderableElement:
						return e.get_content()
					return null
			)
		return []

func initialize():
	add_script(5)
	super()


func reset():
	super()


func add_script(nb_scripters := 1):
	for i in range(nb_scripters):
		var new_script = Scripter.create()
		OrderableElement.create(Globals.get_scripter_container(), new_script)
		scripters.append(new_script)


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
