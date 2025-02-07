extends AbstractManager

var scripters: Array[Scripter]


func initialize():
	add_script()
	super()


func reset():
	super()


func add_script():
	var new_script = Scripter.create()
	scripters.append(new_script)


func _process(_delta):
	if GameManager.in_fight:
		for scripter: Scripter in scripters:
			scripter.do_action()
