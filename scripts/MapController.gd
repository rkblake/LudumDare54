extends TileMap

#[====================   RUNNING LOGIC   ====================]

var time : float = 0
var MAX_TILES : int = 200

var dungeon_location : Sprite 
var dungeon_velocity : Vector2 = Vector2(rand_range(-1,1), rand_range(-1,1)).normalized() * 4
var dungeon_redirect : float = 0

func _physics_process(delta):
	time += delta
	if time >= 0.2:
		#Collapse a part of the dungeon
		if randf() < generation_speed():
			var random_wall : Vector2 = pick_tile_close_to_dungeon(true) #active_walls.keys()[randi() % active_walls.keys().size()]
			change_cell_data(random_wall, floor_tile_index)
		if randf() > generation_speed():
			var random_floor : Vector2 = pick_tile_close_to_dungeon(false) #active_floors.keys()[randi() % active_floors.keys().size()]
			var new_particles = load("res://scenes/CollapseParticles.tscn").instance()
			self.add_child(new_particles)
			new_particles.emitting = true
			new_particles.position = map_to_world(random_floor)
			change_cell_data(random_floor, wall_tile_index)
		
		#Remove floating walls
		for wall_tile in active_walls.keys():
			if active_walls[wall_tile]["neighbors"] == 1:
				change_cell_data(wall_tile, floor_tile_index)
		
		#Remove solo floors
		for floor_tile in active_floors.keys():
			if active_floors[floor_tile]["neighbors"] == 0:
				change_cell_data(floor_tile, wall_tile_index)
		
		#Update bounding boxes for projectiles
		update_bounding_boxes()
		
		time = 0
	
	#Let the dungeon location meander
	dungeon_redirect += delta
	if dungeon_redirect >= 5:
		#print(dungeon_velocity)
		var modifier_velocity : Vector2 = Vector2(rand_range(-1,1), rand_range(-1,1)).normalized() * 2
		dungeon_velocity = (dungeon_velocity + modifier_velocity).normalized() * 4
		dungeon_redirect = 0
	
	dungeon_location.position += dungeon_velocity * delta

#https://www.desmos.com/calculator/5hkvetx2vt
func generation_speed(max_tiles : int = MAX_TILES, floor_size : int = current_floor_size) -> float:
	if floor_size < 0:
		return float(1)
	if floor_size > max_tiles:
		return float(0)
	return sqrt(-1 * ((float(floor_size) - max_tiles) / max_tiles))

#Selects a random tile from the respective active dictionary 
func pick_tile_close_to_dungeon(minimize : bool) -> Vector2:
	#Find tile type to be changed from and setup to find a random tile in that dictionary
	var tile_type : int = wall_tile_index if minimize else floor_tile_index
	var respective_dictionary = get_respective_dictionary(tile_type)
	var random_selection_count : int = clamp(respective_dictionary.size() / 8, 1, INF)
	var current_tile : Vector2 = Vector2(0, 0)
	var current_distance : float = INF if minimize else 0
	
	#itterate through an amount of tiles and pick one that is closest to the room
	for i in random_selection_count:
		var random_tile = respective_dictionary.keys()[randi() % respective_dictionary.keys().size()]
		var distance : float = dungeon_location.position.distance_to(map_to_world(random_tile))
		if (minimize and distance < current_distance) or (!minimize and distance > current_distance):
			current_distance = distance
			current_tile = random_tile
	
	return current_tile

onready var top_left : Position2D = $"../TopLeft"
onready var bottom_right : Position2D = $"../BottomRight"
const SCALE : int = 64

func update_bounding_boxes():
	var tile_rect = self.get_used_rect()
	top_left.position = tile_rect.position * SCALE
	bottom_right.position = tile_rect.end * SCALE
	$"..".update_bounding_rects()

#[====================  TILE MANAGEMENT  ====================]

#Indexes for respective tiles in the attatched Tileset
export var floor_tile_index : int = 0
export var wall_tile_index : int = 1

#Dictionaries of walls and floors to be updated/checked
# Key is tile position and values contain data such as age and neighbors
var active_walls = {}
var active_floors = {}

var current_floor_size : int = 0

const base_tile_dict = {
	"age": 0,
	"neighbors": 0
}

const neighbor_mask = [Vector2(-1, 0), Vector2(0, 1), Vector2(1, 0), Vector2(0, -1)]

func _ready():
	create_dungeon_location()
	initial_check()

func create_dungeon_location():
	dungeon_location = Sprite.new()
	dungeon_location.position = Vector2(136, 80)
	dungeon_location.texture = load("res://icon.png")
	dungeon_location.scale = Vector2(0.125, 0.125)
	dungeon_location.visible = false
	self.add_child(dungeon_location)

func change_cell_data(cell : Vector2, new_tile_index : int) -> void:
	
	#Check for new tile type and that tile is currently in its respective ticking tiles
	var old_cell_tile_index : int = self.get_cellv(cell)
	if old_cell_tile_index != new_tile_index and get_respective_dictionary(old_cell_tile_index).has(cell):
		
		#Remove from previous dictionary and update cell on tilemap
		get_respective_dictionary(old_cell_tile_index).erase(cell)
		change_cell_on_tilemap(cell, new_tile_index)
		
		#Add cell to dictionary and update neighbors
		add_cell_to_dictionary(cell)
		update_neighbors(cell)
	
	#If an empty space is being turned to wall
	if old_cell_tile_index == -1:
		change_cell_on_tilemap(cell, new_tile_index)
		add_cell_to_dictionary(cell)

#Adds cell to respective dictionary
func add_cell_to_dictionary(cell : Vector2, equivalent_neighbors : int = -1, cell_tile_index : int = -2) -> void:
	
	#If nothing is passed for respective variables, calculate values
	if equivalent_neighbors == -1:
		equivalent_neighbors = get_equivalent_neighbors(cell)
	if cell_tile_index == -2:
		cell_tile_index = self.get_cellv(cell)
	
	#Add to dictionary
	var cell_data_dictionary = base_tile_dict.duplicate(true)
	cell_data_dictionary["neighbors"] = equivalent_neighbors
	get_respective_dictionary(cell_tile_index)[cell] = cell_data_dictionary

#NOTE: Critical! Changes cell value which is used to check cell statuses
func change_cell_on_tilemap(cell : Vector2, tile_index : int) -> void:
	
	#Check if a floor tile is being removed and update floor size
	if self.get_cellv(cell) == floor_tile_index and tile_index == wall_tile_index:
		current_floor_size -= 1
		
	#Check if a wall tile is being removed and update floor size
	if self.get_cellv(cell) == wall_tile_index and tile_index == floor_tile_index:
		current_floor_size += 1
	
	#Update tilemap
	self.set_cellv(cell, tile_index)
	self.update_bitmask_area(cell)

#Expensive; Runs check across entire tilemap and populates active tile dictionaries
func initial_check() -> void:
	
	#Reset active cell dictionaries
	active_walls = {}
	active_floors = {}
	
	#Run through placed cells
	var used_cells = self.get_used_cells()
	for cell in used_cells:
		
		if self.get_cellv(cell) == floor_tile_index:
			current_floor_size += 1
		
		#If 4 equivalent neighbors, inert cell, skip
		var equivalent_neighbors : int = get_equivalent_neighbors(cell)
		if equivalent_neighbors == 4:
			continue
		
		#Add to respective active tile dictionary
		add_cell_to_dictionary(cell, equivalent_neighbors)

#Returns int with count of equivalent neighbors
func get_equivalent_neighbors(cell : Vector2) -> int:
	var cell_tile_index : int = self.get_cellv(cell)
	var equivalent_neighbors : int = 0
	for neighbor in neighbor_mask:
		var neighbor_tile_index = self.get_cellv(cell + neighbor)
		if cell_tile_index == neighbor_tile_index or (neighbor_tile_index == -1 and cell_tile_index == wall_tile_index):
			equivalent_neighbors += 1
	return equivalent_neighbors

#Updates all neighbors to given cell; Called when cell is changed
func update_neighbors(cell : Vector2) -> void:
	for neighbor in neighbor_mask:
		
		#Collect cell information and make into a wall if unused
		var current_cell = cell + neighbor
		var neighbor_tile_index : int = self.get_cellv(current_cell)
		
		#If the neighboring tile is empty and we're updating around a floor, make that empty a wall
		if neighbor_tile_index == -1 and self.get_cellv(cell) == floor_tile_index:
			change_cell_data(current_cell, wall_tile_index)
			neighbor_tile_index = wall_tile_index
		
		var equivalent_neighbors = get_equivalent_neighbors(current_cell)
		var respective_dictionary = get_respective_dictionary(neighbor_tile_index)
		
		#If 4 equivalent neighbors, inert cell, continue 
		if equivalent_neighbors == 4:
			#Remove from dictionary if previoisly active
			if respective_dictionary.keys().has(current_cell):
				respective_dictionary.erase(current_cell)
			#If wall, change back to empty 
			if neighbor_tile_index == wall_tile_index:
				change_cell_on_tilemap(current_cell, -1)
			continue
		#Otherwise, check for pre-existing value, add or update respectivly
		else:
			if respective_dictionary.keys().has(current_cell):
				respective_dictionary[current_cell]["neighbors"] = equivalent_neighbors
			else:
				add_cell_to_dictionary(current_cell, equivalent_neighbors, neighbor_tile_index)

#Returns active tile dictionary respective to given tile index
# NOTE: Dictionaries and arrays are passed as pointers in GDScript
func get_respective_dictionary(tile_index : int) -> Dictionary:
	if tile_index == floor_tile_index:
		return active_floors
	elif tile_index == wall_tile_index:
		return active_walls
	return {}
