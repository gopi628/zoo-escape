extends KinematicBody2D

# Signals for collecting items and completing the level
signal collected_star
signal collected_key
signal level_complete

# Size of one tile in pixels
export (int) var tile_size := 32

# Reference to the TileMap set by the Main scene
var tilemap = null

# Last direction moved, used by Elephant for pushing
var last_dir := Vector2(0, 1)

func set_tilemap(tm):
    # Called by the level loader to supply the current TileMap
    tilemap = tm

func _ready():
    # Listen for collectibles entering the detector area
    $Detector.connect("area_entered", self, "_on_Detector_area_entered")

func _input(event):
    # Handle swipe or arrow key input, moving one cell at a time
    if event.is_action_pressed("ui_up"):
        attempt_move(Vector2.UP)
    elif event.is_action_pressed("ui_down"):
        attempt_move(Vector2.DOWN)
    elif event.is_action_pressed("ui_left"):
        attempt_move(Vector2.LEFT)
    elif event.is_action_pressed("ui_right"):
        attempt_move(Vector2.RIGHT)

func attempt_move(dir):
    # Prevent movement without a map
    if tilemap == null:
        return
    var cell = tilemap.world_to_map(position)
    var target = cell + dir
    if is_blocked(target):
        return
    last_dir = dir
    # Move the player to the center of the target tile
    position = tilemap.map_to_world(target) + Vector2(tile_size/2, tile_size/2)
    # Check if the player reached the exit tile
    if tilemap.get_cell(target.x, target.y) == 4:
        emit_signal("level_complete")

func is_blocked(cell):
    # Tiles that block movement
    var id = tilemap.get_cell(cell.x, cell.y)
    return id in [1, 2, 3, 5]

func _on_Detector_area_entered(area):
    # Collect stars and keys using groups
    if area.is_in_group("star"):
        emit_signal("collected_star")
        area.queue_free()
    elif area.is_in_group("key"):
        emit_signal("collected_key")
        area.queue_free()