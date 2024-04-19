extends Node2D

var piece_scene = load("res://Piece.tscn")
@onready var Board = $TileMap
var pieces = []


var current_player = "red"
var selected_piece = null

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initialize_game():
	_initialize_pieces_array()
	for i in range(8):
		for j in range(3):
			if (i + j) % 2 == 1:
				add_piece(piece_scene.instantiate(), Vector2(i, j), "red")
		for j in range(5, 8):
			if (i + j) % 2 == 1:
				add_piece(piece_scene.instantiate(), Vector2(i, j), "black")

func add_piece(piece, grid_pos: Vector2, color: String):
	add_child(piece)
	piece.create_piece(color, Board.map_to_local(grid_pos))
	pieces[grid_pos.x][grid_pos.y] = piece

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var tile_position = Board.local_to_map(event.position)
		if event.pressed:
			print("tile postion %s" % tile_position)
			if _handle_piece_selection(tile_position):
				return
			elif selected_piece != null:
				if !_valid_skip_exists() and _is_valid_move(selected_piece, tile_position):
					_move_piece(selected_piece, tile_position)
					current_player = "red" if current_player == "black" else "black"
				elif _is_valid_skip(selected_piece, tile_position):
					_move_piece_with_skip(selected_piece, tile_position, _get_skipped_piece(Board.local_to_map(selected_piece.position), tile_position))
					

func _handle_piece_selection(tile_position: Vector2):
	var piece_at_clicked_tile = pieces[tile_position.x][tile_position.y]
	if (piece_at_clicked_tile != null and piece_at_clicked_tile.color == current_player):
		if (piece_at_clicked_tile != selected_piece):
			if selected_piece != null:
				selected_piece.select()
			selected_piece = piece_at_clicked_tile
			selected_piece.select()
			return true
		elif piece_at_clicked_tile == selected_piece:
			selected_piece.select()
			selected_piece = null
			return true
	else:
		return false

func _valid_skip_exists():
	for x in range(8):
		for y in range(8):
			var piece = pieces[x][y]
			if piece != null and piece.color == current_player and _piece_has_valid_skip(piece):
				return true
	return false

func _piece_has_valid_skip(piece: Node2D):
	var current_position = Board.local_to_map(piece.position)
	if piece.color == "red":
		if current_position.y + 2 < 8:
			if current_position.x + 2 < 8:
				if _is_valid_skip(piece, Vector2(current_position.x + 2, current_position.y + 2)):
					return true
			if current_position.x - 2 >= 0:
				if _is_valid_skip(piece, Vector2(current_position.x - 2, current_position.y + 2)):
					return true
	elif piece.color == "black":
		if current_position.y - 2 >= 0:
			if current_position.x + 2 < 8:
				if _is_valid_skip(piece, Vector2(current_position.x + 2, current_position.y - 2)):
					return true
			if current_position.x - 2 >= 0:
				if _is_valid_skip(piece, Vector2(current_position.x - 2, current_position.y - 2)):
					return true
	return false

func _get_skipped_piece(start_position: Vector2, end_position: Vector2):
	return pieces[(start_position.x + end_position.x) / 2][(start_position.y + end_position.y) / 2]

func _is_valid_skip(piece, new_position: Vector2):
	var current_position = Board.local_to_map(piece.position)
	var piece_at_target_position = pieces[new_position.x][new_position.y]
	if piece_at_target_position != null:
		return false
	if new_position.x != current_position.x + 2 and new_position.x != current_position.x - 2:
		return false
	if current_player == "red":
		if new_position.y != current_position.y + 2:
			return false
	if current_player == "black":
		if new_position.y != current_position.y - 2:
			return false
	var piece_to_eat = pieces[(new_position.x + current_position.x) / 2][(new_position.y + current_position.y) / 2]
	if piece_to_eat == null or piece_to_eat.color == current_player:
		return false
	return true

func _is_valid_move(piece, new_position: Vector2):
	var current_position = Board.local_to_map(piece.position)

	if new_position.x < 0 or new_position.x >= 8 or new_position.y < 0 or new_position.y >= 8:
		print("move is invalid: 1")
		return false
	
	if current_player == "red":
		if new_position.y != current_position.y + 1:
			print("move is invalid: 2")
			return false

	if current_player == "black":
		if new_position.y != current_position.y - 1:
			print("move is invalid: 4")
			return false

	if new_position.x != current_position.x + 1 and new_position.x != current_position.x - 1:
		print("move is invalid: 5")
		return false
	
	if pieces[new_position.x][new_position.y] != null:
		print("move is invalid: piece at target position")
		return false
	print("move is valid to %d,%d" % [new_position.x, new_position.y])
	return true

func _move_piece_with_skip(piece, new_position: Vector2, skipped_piece: Node2D):
	_move_piece(piece, new_position)
	_clear_piece(skipped_piece)
	if _piece_has_valid_skip(piece):
		piece.select()
		selected_piece = piece
	else:
		current_player = "red" if current_player == "black" else "black"


func _move_piece(piece, new_position: Vector2):
	var current_position = Board.local_to_map(piece.position)
	pieces[current_position.x][current_position.y] = null
	pieces[new_position.x][new_position.y] = piece
	piece.position = Board.map_to_local(new_position)
	piece.select()
	selected_piece = null

func _clear_piece(piece: Node2D):
	var grid_position = Board.local_to_map(piece.position)
	print("clearing piece at %d, %d" % [grid_position.x, grid_position.y])
	pieces[grid_position.x][grid_position.y] = null
	piece.queue_free()
			
func _initialize_pieces_array():
	for i in range(8):
		pieces.append([])
		for j in range(8):
			pieces[i].append(null)
