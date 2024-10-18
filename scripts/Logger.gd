extends Node


func info(message: String):
	print("INFO: %s" % message)


func debug(message: String):
	if Globals.debug:
		print("DEBUG: %s" % message)


func error(message: String):
	push_error("ERROR: %s" % message)
