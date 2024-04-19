extends Node2D

# "red" or "black" or player?
@export_enum("red", "black") var color: String
@export var selected: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func create_piece(col, pos):
	color = col
	position = pos
	print("adding %s piece to %s" % [color, pos])
	if color == "black":
		$BlackIdle.show();
	else:
		$RedIdle.show();

func select():
	if color == "black":
		if selected:
			$BlackIdle.show();
			$BlackSelected.hide();
		else: 
			$BlackIdle.hide();
			$BlackSelected.show();
	else:
		if selected:
			$RedIdle.show();
			$RedSelected.hide();
		else: 
			$RedIdle.hide();
			$RedSelected.show();
	selected = !selected
