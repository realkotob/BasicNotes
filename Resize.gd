extends Panel

# Credit: https://godotengine.org/qa/42706/create-resizable-window

export(bool) var debug_on

var drag_pos = null
var resizing_window:= false
var target_edge := 0
var cursor_type := CURSOR_ARROW
var size_anchor := Vector2(0, 0)
var prev_win_size := Vector2(0,0)
var prev_win_pos := Vector2(0, 0)
var gmouse_pos := Vector2(0, 0)
var lmouse_pos := Vector2(0, 0)
var on_top := false
enum edge {left, top, right, bottom, topl, topr, botl, botr}

func _ready():
	pass

func _draw():
	if (debug_on):
		#Top
		draw_rect(Rect2(Vector2(0,-5), Vector2(get_size().x, 5)),Color( 0.75, 0.75, 0.75, 1 ),false)
		#Left
		draw_rect(Rect2(Vector2(-5,0), Vector2(5, get_size().y)),Color( 0.75, 0.75, 0.75, 1 ),false)
		#Right
		draw_rect(Rect2(Vector2(get_size().x,0), Vector2(5, get_size().y)),Color( 0.75, 0.75, 0.75, 1 ),false)
		#Bottom
		draw_rect(Rect2(Vector2(0,get_size().y), Vector2(get_size().x, 5)),Color( 0.75, 0.75, 0.75, 1 ),false)
	
		#Top Left
		draw_rect(Rect2(Vector2(-6,-5),Vector2(10,10)), Color( 0.75, 0.75, 0.75, 1 ))
		#Top Right
		draw_rect(Rect2(Vector2(get_size().x-5,-5),Vector2(10,10)), Color( 0.75, 0.75, 0.75, 1 ))
		#Bottom Left
		draw_rect(Rect2(Vector2(-6,get_size().y-4),Vector2(10,10)), Color( 0.75, 0.75, 0.75, 1 ))
		#Bottom Right
		#draw_circle(Vector2(get_size().x,get_size().y),5, Color( 0.75, 0.75, 0.75, 1 ))
		draw_rect(Rect2(Vector2(get_size().x-5,get_size().y-4),Vector2(10,10)), Color( 0.75, 0.75, 0.75, 1 ))

func _process(delta):
	on_top = (get_position_in_parent() == 0)
	# Determine Frame Edges
	gmouse_pos = get_global_mouse_position()
	lmouse_pos = get_local_mouse_position()
	
	if not resizing_window:
		# Check If The Mouse Is Targeting an Edge
		target_edge = get_target_edge(get_position(), get_size(), gmouse_pos)
		Input.set_default_cursor_shape(cursor_type)
	
		# Check If An Edge is Selected
		if target_edge != -1 and on_top:
			if Input.is_action_just_pressed("mb_left"):
				size_anchor = Vector2(get_position().x + get_size().x, get_position().y + get_size().y)
				resizing_window = true
	else:
		# Resize Window Based On Edge
		if Input.is_action_pressed("mb_left"):
			resize_window()
		else:
			resizing_window = false

func get_target_edge(win_pos, win_size, mouse_pos):
	var frame_top 	:= Rect2(Vector2(win_pos.x, win_pos.y - 5), Vector2(win_size.x, 5))
	var frame_left 	:= Rect2(Vector2(win_pos.x - 2, win_pos.y), Vector2(2, win_size.y))
	var frame_right := Rect2(Vector2(win_pos.x + win_size.x, win_pos.y), Vector2(2, win_size.y))
	var frame_bot 	:= Rect2(Vector2(win_pos.x, win_pos.y + win_size.y), Vector2(win_size.x, 2))
	
	var frame_topl := Rect2(Vector2(win_pos.x - 2, win_pos.y - 2),Vector2(10,10))
	var frame_topr := Rect2(Vector2(win_pos.x + win_size.x - 2, win_pos.y - 2),Vector2(10,10))
	var frame_botl := Rect2(Vector2(win_pos.x - 2, win_pos.y + win_size.y - 2),Vector2(10,10))
	var frame_botr := Rect2(Vector2(win_pos.x + win_size.x - 2,win_pos.y + win_size.y - 2),Vector2(10,10))
	
	# Determine Mouse Frame Contact
	if frame_topl.has_point(mouse_pos):
		target_edge = edge.topl
	elif frame_topr.has_point(mouse_pos):
		target_edge = edge.topr
	elif frame_botl.has_point(mouse_pos):
		target_edge = edge.botl
	elif frame_botr.has_point(mouse_pos):
		target_edge = edge.botr
	elif frame_left.has_point(mouse_pos):
		target_edge = edge.left
	elif frame_top.has_point(mouse_pos):
		target_edge = edge.top
	elif frame_right.has_point(mouse_pos):
		target_edge = edge.right
	elif frame_bot.has_point(mouse_pos):
		target_edge = edge.bottom
	else:
		target_edge = -1
	
	# Determine Cursor Type
	match target_edge:
		edge.topl, edge.botr:
			cursor_type = CURSOR_FDIAGSIZE
		edge.topr, edge.botl:
			cursor_type = CURSOR_BDIAGSIZE
		edge.top, edge.bottom:
			cursor_type = CURSOR_VSIZE
		edge.left, edge.right:
			cursor_type = CURSOR_HSIZE
		_:
			cursor_type = CURSOR_ARROW
	
	return target_edge

func resize_window():
	match target_edge:
		edge.left:
			set_position(Vector2(gmouse_pos.x, get_position().y))
			set_size(Vector2(size_anchor.x - gmouse_pos.x, get_size().y))
			if (gmouse_pos.x + get_size().x - size_anchor.x) > 0:
				set_position(Vector2(size_anchor.x - get_size().x, get_position().y))
		edge.top:
			set_position(Vector2(get_position().x, gmouse_pos.y))
			set_size(Vector2(get_size().x, size_anchor.y - get_position().y))
			if (gmouse_pos.y + get_size().y - size_anchor.y) > 0:
				set_position(Vector2(get_position().x, size_anchor.y - get_size().y))
		edge.right:
			set_size(Vector2(lmouse_pos.x ,get_size().y))
		edge.bottom:
			set_size(Vector2(get_size().x, lmouse_pos.y))
		edge.topl:
			set_position(Vector2(gmouse_pos.x, gmouse_pos.y))
			set_size(Vector2(size_anchor.x - get_position().x, size_anchor.y - get_position().y))
			if (gmouse_pos.x + get_size().x - size_anchor.x) > 0:
				set_position(Vector2(size_anchor.x - get_size().x, get_position().y))
			if (gmouse_pos.y + get_size().y - size_anchor.y) > 0:
				set_position(Vector2(get_position().x, size_anchor.y - get_size().y))
		edge.topr:
			set_position(Vector2(get_position().x, gmouse_pos.y))
			set_size(Vector2(lmouse_pos.x, size_anchor.y - get_position().y))
			if (gmouse_pos.y + get_size().y - size_anchor.y) > 0:
				set_position(Vector2(get_position().x, size_anchor.y - get_size().y))
		edge.botl:
			set_position(Vector2(gmouse_pos.x, get_position().y))
			set_size(Vector2(size_anchor.x - get_position().x, lmouse_pos.y))
			if (gmouse_pos.x - get_size().x + size_anchor.x) > 0:
				set_position(Vector2(size_anchor.x - get_size().x, get_position().y))
		edge.botr:
			set_size(Vector2(lmouse_pos.x, lmouse_pos.y))
