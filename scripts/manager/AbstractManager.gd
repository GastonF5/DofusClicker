class_name AbstractManager
extends Node

var is_initialized := false

signal initialized


func initialize():
	log.info("Initialisation du manager %s terminée" % name)
	is_initialized = true
	initialized.emit()


func reset():
	is_initialized = false
