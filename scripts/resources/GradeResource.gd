class_name GradeResource
extends Resource


@export var grade: int
@export var monster_id: int
@export var level: int
@export var characteristics: Array[StatResource]
@export var xp: int


static func create(_grade: int, _monster_id: int, _level: int, _xp: int) -> GradeResource:
	var res = GradeResource.new()
	res.grade = _grade;
	res.monster_id = _monster_id
	res.level = _level
	res.xp = _xp
	return res
