extends Node


func info(message: String):
	print("INFO: %s" % message)


func error(message: String):
	push_error("ERROR: %s" % message)
