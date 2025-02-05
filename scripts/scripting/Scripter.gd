class_name Scripter
extends Control


enum TargetOption {
	MAX_HP, MIN_HP, DISTANCE, MELEE, CENTER
}

func get_target_option_label(code: TargetOption) -> String:
	match code:
		TargetOption.MAX_HP: return "Max HP"
		TargetOption.MIN_HP: return "Min HP"
		TargetOption.DISTANCE: return "Distance"
		TargetOption.MELEE: return "Mêlée"
		TargetOption.CENTER: return "Centre"
		_: return "ERROR_%s" % TargetOption.find_key(code)

enum TriggerOption {
	ALWAYS, FIRST, LAST
}

func get_trigger_option_label(code: TriggerOption) -> String:
	match code:
		TriggerOption.ALWAYS: return "Toujours"
		TriggerOption.FIRST: return "En premier"
		TriggerOption.LAST: return "En dernier"
		_: return "ERROR_%" % TriggerOption.find_key(code)

var spell: Spell


static func create() -> Scripter:
	var scripter = preload("res://scenes/scripting/scripter.tscn").instantiate()
	Globals.recipe_script_container.script_container.add_child(scripter)
	return scripter


func _ready():
	for option in TargetOption.values():
		$Options/TargetOptions.add_item(get_target_option_label(option))
	for option in TriggerOption.values():
		$Options/TriggerOptions.add_item(get_trigger_option_label(option))


func get_target_option() -> TargetOption:
	return $Options/TargetOptions.selected


func get_trigget_option() -> TriggerOption:
	return $Options/TriggerOptions.selected
