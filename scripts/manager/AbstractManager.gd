class_name AbstractManager
extends Node

var is_initialized := false

signal initialized


func initialize():
	is_initialized = true
	initialized.emit()


func reset():
	is_initialized = false
