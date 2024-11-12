extends Node


func info(message: String):
	print("INFO: %s" % message)


func debug(message: String, params := []):
	if Globals.debug:
		if params.is_empty():
			print("DEBUG: %s" % message)
		else:
			prints("DEBUG: %s" % message, params)


func error(message: String):
	push_error("ERROR: %s" % message)
