extends "res://scripts/Player.gd"

# Elephant specific ability: push boulders
func _input(event):
    # First allow the base player to handle movement
    ._input(event)
    # Handle push action
    if event.is_action_pressed("push") and tilemap != null:
        var cell = tilemap.world_to_map(position)
        var front = cell + last_dir
        # Check if a boulder is in front
        if tilemap.get_cell(front.x, front.y) == 5:
            var target = front + last_dir
            # Only push if the space beyond is empty floor
            if tilemap.get_cell(target.x, target.y) == 0:
                tilemap.set_cell(front.x, front.y, 0)
                tilemap.set_cell(target.x, target.y, 5)
                # Move into the boulder's previous cell
                position = tilemap.map_to_world(front) + Vector2(tile_size/2, tile_size/2)