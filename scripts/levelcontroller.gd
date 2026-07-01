## Generador procedural de laberintos: crea la grilla lógica, talla el maze y lo renderiza en un TileMap.
extends Node2D

@export_category("Configuración del Laberinto")
@export var width: int = 31 ## El ancho lógico (Debe ser impar)
@export var height: int = 31 ## El alto lógico (Debe ser impar)
@export var path_thickness: int = 10 ## Grosor en tiles de los pasillos y las paredes
@export var entry_point: Vector2i = Vector2i(1, 0)
@export var exit_point: Vector2i = Vector2i(29, 30)
@export var max_enemy_gen : int = 15
@export var tile_border : int = 16
@export var random_halls : bool = false ## Genera secciones anchas aleatoriamente
@export var halls_x : bool = false
@export var halls_y : bool = false
@export var max_halls : int = 4
@export var hall_prob : float = 0.3

@onready var tile_map: TileMapLayer = $Map
@onready var player : Player = $Player

## Constantes de la lógica
const WALL = 0
const PATH = 1

## Configuración del TileMap (Ajusta estos valores según tu TileSet)
const LAYER_ID = 0
const TILE_SOURCE_ID = 0
const ATLAS_WALL = Vector2i(46, 8) ## Coordenada del tile de pared en el atlas
const ATLAS_PATH = Vector2i(36, 35) ## Coordenada del tile de suelo en el atlas

var maze_grid: Array = []
var path_count : int = 0
var summon_count : int = 0
var hall_count : int = 0

func _ready() -> void:
	## El algoritmo requiere dimensiones impares para aislar paredes
	if width % 2 == 0: width += 1
	if height % 2 == 0: height += 1
	player.set_camera_limit(0,tile_border*width*path_thickness, 0, tile_border*height*path_thickness)
	player.transform.origin = Vector2((0.5 + entry_point.x)*tile_border*path_thickness, (0.5 + entry_point.y)*tile_border*path_thickness)
	generate_logic_grid()
	carve_maze()
	force_entry_exit()
	render_to_tilemap()

## 1. Inicializa la matriz bidimensional llena de paredes.
func generate_logic_grid() -> void:
	maze_grid.clear()
	for x in range(width):
		maze_grid.append([])
		for y in range(height):
			maze_grid[x].append(WALL)

## 2. Algoritmo Recursive Backtracker
func carve_maze() -> void:
	var stack: Array[Vector2i] = []
	
	## Iniciar en una celda impar para garantizar el espacio de las paredes
	var start_pos = Vector2i(1, 1)
	maze_grid[start_pos.x][start_pos.y] = PATH
	stack.append(start_pos)

	## Direcciones de salto (se mueven de 2 en 2 para dejar una pared de por medio)
	var dirs = [Vector2i(0, -2), Vector2i(0, 2), Vector2i(-2, 0), Vector2i(2, 0)]

	while not stack.is_empty():
		var current = stack.back()
		var unvisited_neighbors: Array[Vector2i] = []

		for d in dirs:
			var nx = current.x + d.x
			var ny = current.y + d.y

			## Verificar límites 
			if nx > 0 and nx < width - 1 and ny > 0 and ny < height - 1:
				if maze_grid[nx][ny] == WALL:
					unvisited_neighbors.append(d)

		if unvisited_neighbors.size() > 0:
			## Escoger un vecino al azar
			var dir = unvisited_neighbors[randi() % unvisited_neighbors.size()]
			var next_cell = Vector2i(current.x + dir.x, current.y + dir.y)
			var wall_between = Vector2i(current.x + dir.x / 2, current.y + dir.y / 2)


			## Romper la pared y marcar la nueva celda como camino
			maze_grid[wall_between.x][wall_between.y] = PATH
			maze_grid[next_cell.x][next_cell.y] = PATH
			
			stack.append(next_cell)
		else:
			stack.pop_back()

	for x in range(width):
		for y in range(height):
			if maze_grid[x][y] == PATH:
				path_count += 1
			else:
				if random_halls && hall_count<max_halls && randf_range(0,1)<hall_prob:
					if x>0 && y>0 && x<width-1 && y<height-1 :
						if halls_x:
							var xi = x
							while maze_grid[xi][y] == WALL:
								maze_grid[xi][y] = PATH
								xi += 1
						elif halls_y:
							var yi = y
							while maze_grid[x][yi] == WALL:
								maze_grid[x][yi] = PATH
								yi += 1
						hall_count += 1

## 3. Forzar las aperturas del inicio y fin
func force_entry_exit() -> void:
	## Entrada
	maze_grid[entry_point.x][entry_point.y] = PATH
	## Conectar la entrada hacia adentro si está en el borde superior
	if entry_point.y == 0:
		maze_grid[entry_point.x][1] = PATH

	## Salida 
	maze_grid[exit_point.x][exit_point.y] = PATH
	## Conectar la salida hacia adentro si está en el borde inferior
	if exit_point.y == height - 1:
		maze_grid[exit_point.x][height - 2] = PATH

## 4. Escalar y dibujar en el TileMap. Agregar enemigos items y salidas
func render_to_tilemap() -> void:
	tile_map.clear()
	for x in range(width):
		for y in range(height):
			var is_path = (maze_grid[x][y] == PATH)
			var atlas_coord = ATLAS_PATH if is_path else ATLAS_WALL
			if is_path:
				if summon_count < max_enemy_gen :
					var summon : bool
					summon =  randf_range(0,1) <=(float(max_enemy_gen)/float(path_count))
					if summon:
						var enemy : Sprite2D = Sprite2D.new()
						enemy.transform.origin = Vector2((0.5 + x)*tile_border*path_thickness, (0.5 + y)*tile_border*path_thickness)
						enemy.z_index = 0
						enemy.y_sort_enabled = true
						var tex = CompressedTexture2D.new()
						tex.load("res://.godot/imported/demosprite2.png-f305426de02dab3dac67efa71c52ed42.ctex")
						enemy.texture = tex
						add_child(enemy)
						summon_count += 1
			## Multiplicar la coordenada lógica por el grosor deseado
			for tx in range(path_thickness):
				for ty in range(path_thickness):
					var tile_x = (x * path_thickness) + tx
					var tile_y = (y * path_thickness) + ty
					tile_map.set_cell(Vector2i(tile_x, tile_y), TILE_SOURCE_ID, atlas_coord)
