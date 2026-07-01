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


const ZONA_PISABLE_SCENE = preload("res://scenes/map/staircase.tscn")
# Constantes de la lógica
const WALL = 1
const PATH = 0

# Configuración del TileMap (Ajusta estos valores según tu TileSet)
const LAYER_ID = 0
const TILE_SOURCE_ID = 0
var ATLAS_WALL_SET : Array
var ATLAS_FLOOR_SET : Array
const ATLAS_ROOF_WALK = Vector2i(0, 0)
const ATLAS_ROOF = Vector2i(0, 1)
const ATLAS_STAIRCASE = Vector2i(56,68)

var maze_grid: Array = []
var path_count : int = 0
var summon_count : int = 0
var hall_count : int = 0

# Direcciones cardinales y sus valores de bit correspondientes
const NORTH = 1
const EAST = 2

const SOUTH = 4
const WEST = 8
const GET_ATTP : int = 10

func _ready() -> void:
	get_tree().paused = false
	ATLAS_WALL_SET = []
	ATLAS_WALL_SET.append(Vector2i(0, 68))
	ATLAS_WALL_SET.append(Vector2i(8, 68))
	ATLAS_WALL_SET.append(Vector2i(4, 68))
	ATLAS_WALL_SET.append(Vector2i(0, 76))
	ATLAS_WALL_SET.append(Vector2i(0, 52))
	ATLAS_WALL_SET.append(Vector2i(0, 44))
	ATLAS_WALL_SET.append(Vector2i(0, 60))
	ATLAS_FLOOR_SET = []
	ATLAS_FLOOR_SET.append(Vector2i(56, 20))
	ATLAS_FLOOR_SET.append(Vector2i(56, 32))
	ATLAS_FLOOR_SET.append(Vector2i(56, 44))
	ATLAS_FLOOR_SET.append(Vector2i(56, 56))
	
	# El algoritmo requiere dimensiones impares para aislar paredes
	if width % 2 == 0: width += 1
	if height % 2 == 0: height += 1
	var attp : int = 0
	var gen : bool = false
	while gen == false && attp < GET_ATTP: 
		generate_logic_grid()
		gen = carve_maze()
		attp += 1
	force_entry_exit()
	maze_grid = generar_matriz_muros(maze_grid)
	render_to_tilemap()
	player.set_camera_limit(0,tile_border*width*path_thickness, 0, tile_border*height*path_thickness)
	player.transform.origin = Vector2((0.5 + entry_point.x)*tile_border*path_thickness, (-0.5 + entry_point.y)*tile_border*path_thickness)
	await get_tree().process_frame
	player.camera.position_smoothing_enabled = true

## Procesa la matriz binaria y devuelve la matriz de tipos de muro
func generar_matriz_muros(mapa_binario: Array) -> Array:
	if mapa_binario.is_empty():
		return []
		
	var ancho = mapa_binario.size()       # Ahora el primer nivel son las Columnas (X)
	var alto = mapa_binario[0].size()     # El segundo nivel son las Filas (Y)
	
	# Inicializar la matriz traspuesta de salida [x][y]
	var mapa_tipos = []
	for x in range(ancho):
		var columna = []
		columna.resize(alto)
		columna.fill(0)
		mapa_tipos.append(columna)
	
	# Recorrer usando X como bucle externo e Y como interno
	for x in range(ancho):
		for y in range(alto):
			# Si no es muro, se queda en 0
			if mapa_binario[x][y] == 0:
				mapa_tipos[x][y] = 0
				continue
			
			var mask = 0
			
			# 1. Validar Arriba (y - 1)
			if y > 0 and mapa_binario[x][y - 1] == 1:
				mask |= NORTH
				
			# 2. Validar Derecha (x + 1)
			if x < ancho - 1 and mapa_binario[x + 1][y] == 1:
				mask |= EAST
				
			# 3. Validar Abajo (y + 1)
			if y < alto - 1 and mapa_binario[x][y + 1] == 1:
				mask |= SOUTH
				
			# 4. Validar Izquierda (x - 1)
			if x > 0 and mapa_binario[x - 1][y] == 1:
				mask |= WEST
			
			mapa_tipos[x][y] = mask
			
	return mapa_tipos



# 1. Inicializa la matriz bidimensional llena de paredes
func generate_logic_grid() -> void:
	maze_grid.clear()
	for x in range(width):
		maze_grid.append([])
		for y in range(height):
			maze_grid[x].append(WALL)

# 2. Algoritmo Recursive Backtracker
func carve_maze() -> bool:
	var stack: Array[Vector2i] = []
	
	# Iniciar en una celda impar para garantizar el espacio de las paredes
	var start_pos = Vector2i(1, 1)
	maze_grid[start_pos.x][start_pos.y] = PATH
	stack.append(start_pos)

	# Direcciones de salto (se mueven de 2 en 2 para dejar una pared de por medio)
	var dirs = [Vector2i(0, -2), Vector2i(0, 2), Vector2i(-2, 0), Vector2i(2, 0)]

	while not stack.is_empty():
		var current = stack.back()
		var unvisited_neighbors: Array[Vector2i] = []

		for d in dirs:
			var nx = current.x + d.x
			var ny = current.y + d.y

			# Verificar límites
			if nx > 0 and nx < width - 1 and ny > 0 and ny < height - 1:
				if maze_grid[nx][ny] == WALL:
					unvisited_neighbors.append(d)

		if unvisited_neighbors.size() > 0:
			# Escoger un vecino al azar
			var dir = unvisited_neighbors[randi() % unvisited_neighbors.size()]
			var next_cell = Vector2i(current.x + dir.x, current.y + dir.y)
			var wall_between = Vector2i(current.x + dir.x / 2, current.y + dir.y / 2)

			# Romper la pared y marcar la nueva celda como camino
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
			if x == width:
				maze_grid[x][y] == WALL
	return true
# 3. Forzar las aperturas del inicio y fin
func force_entry_exit() -> void:
	# Entrada
	maze_grid[entry_point.x][entry_point.y] = WALL
	# Conectar la entrada hacia adentro si está en el borde superior
	if entry_point.y == 0:
		maze_grid[entry_point.x][1] = PATH

	# Salida
	maze_grid[exit_point.x][exit_point.y] = WALL
	# Conectar la salida hacia adentro si está en el borde inferior
	if exit_point.y == height - 1:
		maze_grid[exit_point.x][height - 2] = PATH

func set_tileset(type,ix,iy) -> void:
	var atlas_coord : Vector2
	var atlas_wall = ATLAS_WALL_SET[randi_range(0,ATLAS_WALL_SET.size()-1)]
	var atlas_floor = ATLAS_FLOOR_SET[randi_range(0,ATLAS_FLOOR_SET.size()-1)]
	var excludeS = [4,5,6,7,12,13,14,15]
	var excludeN = [2,4,6,8,10,12,14,15]
	if type == -1:
		atlas_coord = ATLAS_STAIRCASE
	elif type == 0:
		atlas_coord = atlas_floor 
	else:
		atlas_coord = atlas_wall
	for tx in range(path_thickness):
		for ty in range(path_thickness):
			var tile_x = (ix * path_thickness) + tx
			var tile_y = (iy * path_thickness) + ty
			if type == 0 || type == -1:
				tile_map.set_cell(Vector2i(tile_x, tile_y), TILE_SOURCE_ID, atlas_coord+Vector2.RIGHT*tx + Vector2.DOWN*ty)
			elif type in excludeS || iy == height-1:
				if ty < 2 && type in excludeN:
					tile_map.set_cell(Vector2i(tile_x, tile_y), TILE_SOURCE_ID, ATLAS_ROOF_WALK)
				else:
					tile_map.set_cell(Vector2i(tile_x, tile_y), TILE_SOURCE_ID, ATLAS_ROOF)
			elif ty < 2 && type in excludeN:
				tile_map.set_cell(Vector2i(tile_x, tile_y), TILE_SOURCE_ID, ATLAS_ROOF_WALK)
			elif ty < 4:
				tile_map.set_cell(Vector2i(tile_x, tile_y), TILE_SOURCE_ID, ATLAS_ROOF)
			else:
				tile_map.set_cell(Vector2i(tile_x, tile_y), TILE_SOURCE_ID, atlas_coord+Vector2.RIGHT*(tx) + Vector2.DOWN*(ty-4))
# 4. Escalar y dibujar en el TileMap. Agregar enemigos items y salidas
func render_to_tilemap() -> void:
	tile_map.clear()
	for x in range(width):
		for y in range(height):
			var is_path = (maze_grid[x][y] == 0)
			set_tileset(maze_grid[x][y],x,y)
			# Genera enemigos y props
			if is_path && (Vector2i(x,y) != entry_point) && (Vector2i(x,y) != exit_point - Vector2i.UP) :
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
	# Genera entrada y salida
	set_tileset(-1,exit_point.x, exit_point.y)
	var nueva_area = ZONA_PISABLE_SCENE.instantiate()
	# 3. Calculamos la posición global del centro de ese Tile
	# 'map_to_local' nos da el centro del tile en píxeles
	nueva_area.global_position = Vector2((0.5 + exit_point.x)*tile_border*path_thickness, (0.5 + exit_point.y)*tile_border*path_thickness)
	
	# 4. La añadimos a la escena (puede ser como hijo del mapa o del tilemap)
	add_child(nueva_area)
