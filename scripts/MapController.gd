extends TileMap

#[====================   RUNNING LOGIC   ====================]

var time : float = 0
const MAX_TILES : int = 500

func _physics_process(delta):
	time += delta
	if time >= 1.0:
#		print("Dungeon change tick")
		if randf() < generation_speed():
#			print(" Changing...")
			var random_floor = active_floors.keys()[randi() % active_floors.keys().size()]
			var random_wall = active_walls.keys()[randi() % active_walls.keys().size()]
			change_cell_data(random_floor, wall_tile_index)
			change_cell_data(random_wall, floor_tile_index)
		time = 0

#https://www.desmos.com/calculator/5hkvetx2vt
func generation_speed(max_tiles : int = MAX_TILES, floor_size : int = current_floor_size) -> float:
	return sqrt(-1 * ((float(floor_size) - max_tiles) / max_tiles))
	
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
	initial_check()
	print(current_floor_size)

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
	if self.get_cellv(cell) == floor_tile_index and tile_index != floor_tile_index:
		current_floor_size -= 1
	
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
		if cell_tile_index == neighbor_tile_index or neighbor_tile_index == -1:
			equivalent_neighbors += 1
	return equivalent_neighbors

#Updates all neighbors to given cell; Called when cell is changed
func update_neighbors(cell : Vector2) -> void:
	for neighbor in neighbor_mask:
		
		#Collect cell information
		var current_cell = cell + neighbor
		var neighbor_tile_index : int = self.get_cellv(current_cell)
		var equivalent_neighbors = get_equivalent_neighbors(current_cell)
		var respective_dictionary = get_respective_dictionary(neighbor_tile_index)
		
		#If 4 equivalent neighbors, inert cell, remove if previously active, remove from dictionary and continute
		if equivalent_neighbors == 4:
			respective_dictionary.erase(current_cell)
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
