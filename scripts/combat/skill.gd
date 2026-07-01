class_name Skill extends RefCounted

var nombre: String
var poder: int

func _init(_nombre: String, _poder: int):
	nombre = _nombre
	poder = _poder

func ejecutar(usuario: Entity, objetivo: Entity) -> String:
	return ""
