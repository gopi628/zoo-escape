extends Node2D

# Paths to levels and animal scenes
var levels = ["res://levels/Level1.tscn"]
var current_level := 0
var star_count := 0
var key_count := 0

var player_scene = preload("res://scenes/elephant.tscn")
var player = null

onready var maze := $Maze
onready var star_label := $UI/HBoxContainer/StarLabel
onready var key_label := $UI/HBoxContainer/KeyLabel
onready var next_button := $UI/HBoxContainer/NextButton

func _ready():
    # Spawn the default animal
    spawn_player()
    # Connect UI buttons
    $UI/HBoxContainer/RestartButton.connect("pressed", self, "_on_restart")
    next_button.connect("pressed", self, "_on_next")
    # Load first level
    load_level(current_level)

func spawn_player():
    # Remove any existing player
    if player:
        player.queue_free()
    player = player_scene.instance()
    add_child(player)
    player.connect("collected_star", self, "_on_star")
    player.connect("collected_key", self, "_on_key")
    player.connect("level_complete", self, "_on_level_complete")

func load_level(index):
    # Clear Maze tiles and load the level TileMap resource
    maze.clear()
    var level = load(levels[index]).instance()
    maze.tile_set = level.tile_set
    maze.tile_data = level.tile_data
    # Place player at starting cell (1,1)
    var start_cell = Vector2(1,1)
    player.position = maze.map_to_world(start_cell) + Vector2(maze.cell_size.x/2, maze.cell_size.y/2)
    player.set_tilemap(maze)
    # Spawn collectibles based on special tiles
    spawn_collectibles(6, "res://scenes/Star.tscn")
    spawn_collectibles(7, "res://scenes/Key.tscn")
    star_count = 0
    key_count = 0
    update_ui()
    next_button.disabled = true

func spawn_collectibles(tile_id, scene_path):
    var cells = maze.get_used_cells_by_id(tile_id)
    var scene = load(scene_path)
    for c in cells:
        maze.set_cell(c.x, c.y, 0)
        var item = scene.instance()
        add_child(item)
        item.position = maze.map_to_world(c) + Vector2(maze.cell_size.x/2, maze.cell_size.y/2)

func _on_star():
    star_count += 1
    update_ui()

func _on_key():
    key_count += 1
    update_ui()

func _on_level_complete():
    next_button.disabled = false

func _on_restart():
    load_level(current_level)

func _on_next():
    current_level += 1
    if current_level >= levels.size():
        current_level = 0
    load_level(current_level)

func update_ui():
    star_label.text = "Stars: %d" % star_count
    key_label.text = "Keys: %d" % key_count