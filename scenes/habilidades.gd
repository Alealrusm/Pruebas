extends Control

@onready var btn_especial: Button = $CenterContainer/Scale/VBox/BtnEspecial
@onready var btn_defensa: Button = $CenterContainer/Scale/VBox/BtnDefensa
@onready var btn_curar: Button = $CenterContainer/Scale/VBox/BtnCurar
@onready var label_seleccion: Label = $CenterContainer/Scale/LabelSeleccion
@onready var btn_confirmar: Button = $CenterContainer/Scale/BtnConfirmar
@onready var btn_salir: Button = $CenterContainer/Scale/BtnSalir

# Usamos índices en vez de referencias a objetos
var indices_seleccionados: Array = []
const MAX_ELEGIDAS = 2

func _ready() -> void:
	# Restaurar selección previa por índice
	indices_seleccionados = []
	for hab in Global.habilidades_elegidas:
		var idx = Global.habilidades_disponibles.find(hab)
		if idx != -1:
			indices_seleccionados.append(idx)
	_actualizar_ui()
	btn_especial.grab_focus()


func _on_btn_especial_pressed() -> void:
	_toggle(0, btn_especial)

func _on_btn_defensa_pressed() -> void:
	_toggle(1, btn_defensa)

func _on_btn_curar_pressed() -> void:
	_toggle(2, btn_curar)

func _toggle(indice: int, boton: Button) -> void:
	if indice in indices_seleccionados:
		indices_seleccionados.erase(indice)
	elif indices_seleccionados.size() < MAX_ELEGIDAS:
		indices_seleccionados.append(indice)
	_actualizar_ui()

func _actualizar_ui() -> void:
	if Global.habilidades_disponibles.is_empty():
		return
	
	label_seleccion.text = "Habilidades elegidas: %d/%d" % [indices_seleccionados.size(), MAX_ELEGIDAS]
	btn_confirmar.disabled = indices_seleccionados.size() != MAX_ELEGIDAS
	
	btn_especial.text = ("[X] " if 0 in indices_seleccionados else "[ ] ") + "Ataque Especial"
	btn_defensa.text  = ("[X] " if 1 in indices_seleccionados else "[ ] ") + "Defensa"
	btn_curar.text    = ("[X] " if 2 in indices_seleccionados else "[ ] ") + "Curar"

func _on_confirmar_pressed() -> void:
	Global.habilidades_elegidas = []
	for idx in indices_seleccionados:
		Global.habilidades_elegidas.append(Global.habilidades_disponibles[idx])
	get_tree().change_scene_to_file(Global.escena_origen if not Global.escena_origen.is_empty() else "res://scenes/test.tscn")

func _on_salir_pressed() -> void:
	Global.abrir_pausa_al_volver = true
	var escena = Global.escena_origen if not Global.escena_origen.is_empty() else "res://scenes/test.tscn"
	get_tree().change_scene_to_file(escena)
