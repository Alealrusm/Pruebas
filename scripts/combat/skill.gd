## Clase base de habilidades. Define nombre y poder; ejecutar() se sobreescribe en subclases.
class_name Skill extends RefCounted

var nombre: String
var poder: int

func _init(_nombre: String, _poder: int):
	nombre = _nombre
	poder = _poder

## Método base vacío, implementado por AttackSkill, DefendSkill y HealSkill.
func ejecutar(usuario: Entity, objetivo: Entity) -> String:
	return ""
