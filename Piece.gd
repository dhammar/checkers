extends Node2D

# "red" or "black" or player?
@export_enum("red", "black") var color: String
@export var selected: bool
@export var king: bool

var sprite;
var selected_sprite;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func create_piece(col, pos):
	color = col
	position = pos
	print("adding %s piece to %s" % [color, pos])
	if color == "black":
		sprite = $BlackIdle;
		selected_sprite = $BlackSelected;
	else:
		sprite = $RedIdle;
		selected_sprite = $RedSelected;
	sprite.show()

func select():
	selected = !selected
	if selected:
		sprite.hide()
		selected_sprite.show()
	else:
		selected_sprite.hide()
		sprite.show()

func set_king():
	king = true
	sprite.hide()
	if color == "black":
		sprite = $BlackKingIdle
		selected_sprite = $BlackKingSelected
	else:
		sprite = $RedKingIdle
		selected_sprite = $RedKingSelected
	sprite.show()
