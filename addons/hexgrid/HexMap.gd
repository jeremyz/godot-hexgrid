@icon('res://addons/hexgrid/HexMap.png')
extends Node

class_name HexMap

enum Orientation { E=1, NE=2, N=4, NW=8, W=16, SW=32, S=64, SE=128 }

const IMAX : int = 9999999999
const DEGREE_ADJ : int = 2

var bt : Vector2	# bottom corner
var cr : Vector2	# column, row

var v : bool		# hex have a vertical edje

var s : float		# hex side length
var w : float		# hex width between 2 parallel sides
var h : float		# hex height from the bottom of the middle rectangle to the top of the upper edje
var dw : float		# half width
var dh : float		# half height (from the top ef tho middle rectangle to the top of the upper edje)
var m : float		# dh / dw
var im : float		# dw / dh
var tl : int		# num of hexes in 2 consecutives rows

var tile_factory_fct : Callable
var angles : Dictionary
var adjacents : Array
var search_count : int
var stack : Array

func _init(cols : int, rows : int, side : float, v0 : Vector2, vertical : bool, fct : Callable) -> void:
	tile_factory_fct = fct
	v = vertical
	s = side
	w  = s * 1.73205
	dw = w / 2.0
	dh = s / 2.0
	h  = s + dh
	m = dh / dw
	im = dw / dh
	if v:
		bt = v0
		cr = Vector2(cols, rows)
	else:
		bt = v0
		cr = Vector2(rows, cols)
	tl = (2 * int(cr.x) - 1)
	search_count = 0
	angles = {}
	if v:
		# origin [top-left] East is at 0°, degrees grows clockwise
		angles[Orientation.E] = 0
		angles[Orientation.SE] = 60
		angles[Orientation.SW] = 120
		angles[Orientation.W] = 180
		angles[Orientation.NW] = 240
		angles[Orientation.NE] = 300
	else:
		angles[Orientation.SE] = 30
		angles[Orientation.S] = 90
		angles[Orientation.SW] = 150
		angles[Orientation.NW] = 210
		angles[Orientation.N] = 270
		angles[Orientation.NE] = 330

# the number of Tile
func size() -> int:
	return int(cr.y) / 2 * tl + int(cr.y) % 2 * int(cr.x)

# fetch a Tile given it's col;row coordinates
func get_tile(coords : Vector2) -> Tile:
	return tile_factory_fct.call(coords, key(coords))

# Orientation to degrees
func to_degrees(o : int) -> int:
	return angles.get(o, -1)

# convert the given angle between 2 adjacent Tiles into an Orientation
func to_orientation(a : float) -> int:
	for k in angles.keys():
		if angles[k] == a:
			return k
	return -1

# compute the angle between 2 adjacent Tiles
func angle(from : Tile, to : Tile) -> int:
	var a : float = rad_to_deg((to.position - from.position).angle()) + DEGREE_ADJ
	if a < 0: a += 360
	return int(a / 10) * 10

# return the opposite of a given Orientation
func opposite(o : int) -> int:
	if o <= Orientation.NW: return o << 4
	return o >> 4

# return the Orientation given to distant Tiles
# Orientation is combined in case of diagonals
func distant_orientation(from : Tile, to : Tile) -> int:
	var a : float = rad_to_deg((to.position - from.position).angle())
	if a < 0: a += 360
	a = int(a * 10) / 10.0
	for k in angles.keys():
		var z : int = angles[k]
		if a >= (z + 30 - DEGREE_ADJ) and a <= (z + 30 + DEGREE_ADJ):
			# diagonal
			var p : int = k >> 1
			if p == 0: p = Orientation.SE
			if not angles.has(p): return k | p >> 1 # v : N S and not v : W E
			else: return (k | p)
		elif (z == 30 and (a < DEGREE_ADJ or a > 360 - DEGREE_ADJ)):
			return Orientation.NE | Orientation.SE
		elif a >= (z - 30) and a <= (z + 30):
			return k
	if angles.has(Orientation.E) and a > 330 and a <= 360:
		return Orientation.E
	return -1

# return the opposite of a possibly combined given Orientation
func distant_opposite(o : int) -> int:
	var r : int = 0
	for k in angles.keys():
		if (k & o) == k:
			r |= opposite(k)
	return r

# return the key of a given col;row coordinate
func key(coords : Vector2) -> int:
	if not is_on_map(coords): return -1
	if v: return _key(int(coords.x), int(coords.y))
	else: return _key(int(coords.y), int(coords.x))

func _key(x : int, y : int) -> int:
	var n : int = y / 2
	var i : int =  x - n + n * tl
	if (y % 2) != 0:
		i += (int(cr.x) - 1)
	return i

# build the 6 adjacent Tiles of a Tile given by it's col;row coordinates
func adjacents_of(tile : Tile, tiles : Array) -> void:
	tiles.clear()
	for t in _build_adjacents(tile.coords): tiles.append(t)

func _build_adjacents(coords : Vector2) -> Array:
	adjacents.clear()
	coords.x += 1
	adjacents.append(get_tile(coords))
	coords.y += 1
	adjacents.append(get_tile(coords))
	coords.x -= 1
	adjacents.append(get_tile(coords))
	coords.x -= 1
	coords.y -= 1
	adjacents.append(get_tile(coords))
	coords.y -= 1
	adjacents.append(get_tile(coords))
	coords.x += 1
	adjacents.append(get_tile(coords))
	return adjacents

# return true if the Tile is on the map
func is_on_map(coords : Vector2) -> bool:
	if v: return _is_on_map(int(coords.x), int(coords.y))
	else: return _is_on_map(int(coords.y), int(coords.x))

func _is_on_map(x : int, y : int) -> bool:
	if (y < 0) || (y >= int(cr.y)): return false
	if (x < ((y + 1) / 2)) || (x >= (int(cr.x) + (y / 2))): return false
	return true

# compute the center of a Tile given by it's col;row coordinates
func center_of(coords : Vector2) -> Vector2:
	if v: return Vector2(bt.x + dw + (coords.x * w) - (coords.y * dw), bt.y + dh + (coords.y * h))
	else: return Vector2(bt.y + dh + (coords.x * h), bt.x + dw + (coords.y * w) - (coords.x * dw))

# compute the col;row coordinates of a Tile given it's real coordinates
func to_map(r : Vector2) -> Vector2:
	if v: return _to_map(r.x, r.y, false)
	else: return _to_map(r.y, r.x, true)

func _to_map(x : float, y : float, swap : bool) -> Vector2:
	var col : int = -1
	var row : int = -1
	# compute row
	var dy : float = y - bt.y
	row = int(dy / h)
	if dy < 0:
		row -= 1
	# compute col
	var dx : float = x - bt.x + (row * dw);
	col = int(dx / w)
	if dx < 0:
		col -= 1
	# upper rectangle or hex body
	if dy > ((row * h) + s):
		dy -= ((row * h) + s)
		dx -= (col * w)
		# upper left or right rectangle
		if dx < dw:
			if dy > (dx * m):
				# upper left hex
				row += 1
		else:
			if dy > ((w - dx) * m):
				# upper right hex
				row += 1
				col += 1
	if swap: return Vector2(row, col)
	else: return Vector2(col, row)

# compute the distance between 2 Tiles given by their col;row coordinates
func distance(p0 : Vector2, p1 : Vector2, euclidean : bool = true) -> float:
	var dx : int = int(p1.x - p0.x)
	var dy : int = int(p1.y - p0.y)
	if euclidean:
		if dx == 0: return abs(dy)
		elif dy == 0 || dx == dy: return abs(dx)
		var fdx : float = dx - dy / 2;
		var fdy : float = dy * 0.86602
		return sqrt((fdx * fdx) + (fdy * fdy))
	else:
		dx = int(abs(dx))
		dy = int(abs(dy))
		var dz : float = abs(p1.x - p0.x - p1.y + p0.y)
		if dx > dy:
			if dx > dz: return float(dx)
		else:
			if dy > dz: return float(dy)
		return dz

# http://zvold.blogspot.com/2010/01/bresenhams-line-drawing-algorithm-on_26.html
# http://zvold.blogspot.com/2010/02/line-of-sight-on-hexagonal-grid.html
# compute as an Array, the line of sight between 2 Tiles given by their col;row coordinates
# return the point after which the line of sight is blocked
func line_of_sight(p0 : Vector2, p1 : Vector2, tiles : Array) -> Vector2:
	tiles.clear()
	# orthogonal projection
	var ox0 : float = p0.x - (p0.y + 1) / 2
	var ox1 : float = p1.x - (p1.y + 1) / 2
	var dy : int = int(p1.y) - int(p0.y)
	var dx : float = ox1 - ox0
	# quadrant I && III
	var q13 : bool = (dx >= 0 && dy >= 0) || (dx < 0 && dy < 0)
	# is positive
	var xs : int = 1
	var ys : int = 1
	if dx < 0: xs = -1
	if dy < 0: ys = -1
	# dx counts half width
	dy = int(abs(dy))
	dx = abs(2 * dx)
	var dx3 : int = int(3 * dx)
	var dy3 : int = 3 * dy
	# check for diagonals
	if dx == 0 || dx == dy3:
		return _diagonal_los(p0, p1, (dx == 0), q13, tiles)
	# angle is less than 45°
	var flat : bool = dx > dy3
	var x : int = int(p0.x)
	var y : int = int(p0.y);
	var e : int = int(-2 * dx)
	var from : Tile = get_tile(p0)
	var to : Tile = get_tile(p1)
	var d : float = distance(p0, p1)
	tiles.append(from)
	from.blocked = false
	var ret : Vector2 = Vector2(-1, -1)
	var contact : bool = false
	var los_blocked : bool = false
	while (x != p1.x) or (y != p1.y):
		if e > 0:
			# quadrant I : up left
			e -= (dy3 + dx3)
			y += ys
			if not q13: x -= xs
		else:
			e += dy3
			if (e > -dx) or (not flat && (e == -dx)):
				# quadrant I : up right
				e -= dx3
				y += ys
				if q13: x += xs
			elif e < -dx3:
				# quadrant I : down right
				e += dx3
				y -= ys
				if not q13: x += xs
			else:
				# quadrant I : right
				e += dy3
				x += xs
		var q : Vector2 = Vector2(x, y)
		var t : Tile = get_tile(q)
		if los_blocked and not contact:
			var prev : Tile = tiles[tiles.size() - 1]
			var o : int = to_orientation(angle(prev, t))
			ret = _compute_contact(from.position, to.position, prev.position, o)
			contact = true
		tiles.append(t)
		t.blocked = los_blocked
		los_blocked = los_blocked or t.block_los(from, to, d, distance(p0, q))
	return ret

func _diagonal_los(p0 : Vector2, p1 : Vector2, flat : bool, q13 : bool, tiles : Array) -> Vector2:
	var dy : int = 1 if p1.y > p0.y else -1
	var dx : int = 1 if p1.x > p0.x else -1
	var x : int = int(p0.x)
	var y : int = int(p0.y)
	var from : Tile = get_tile(p0);
	var to : Tile = get_tile(p1);
	var d : float = distance(p0, p1)
	tiles.append(from);
	from.blocked = false;
	var ret : Vector2 = Vector2(-1, -1)
	var blocked : int = 0
	var contact : bool = false
	var los_blocked : bool = false
	while (x != p1.x) or (y != p1.y):
		var idx : int = 4
		if flat: y += dy	# up left
		else: x += dx		# right
		var q : Vector2 = Vector2(x, y)
		var t : Tile = get_tile(q)
		if t.on_map:
			tiles.append(t)
			t.blocked = los_blocked
			if t.block_los(from, to, d, distance(p0, q)):
				blocked |= 0x01
		else:
			blocked |= 0x01
			idx = 3

		if flat: x += dx	# up right
		else:
			y += dy		# up right
			if not q13: x -= dx
		q = Vector2(x, y)
		t = get_tile(q)
		if t.on_map:
			tiles.append(t)
			t.blocked = los_blocked
			if t.block_los(from, to, d, distance(p0, q)):
				blocked |= 0x02
		else:
			blocked |= 0x02
			idx = 3

		if flat: y += dy	# up
		else: x += dx 		# diagonal
		q = Vector2(x, y)
		t = get_tile(q)
		tiles.append(t)
		t.blocked = los_blocked || blocked == 0x03
		if t.blocked and not contact:
			var o : int = _compute_orientation(dx, dy, flat)
			if not los_blocked and blocked == 0x03:
				ret = _compute_contact(from.position, to.position, t.position, opposite(o))
			else:
				ret = _compute_contact(from.position, to.position, tiles[tiles.size() - idx].position, o)
			contact = true;
		los_blocked = t.blocked || t.block_los(from, to, d, distance(p0, q))
	return ret

func _compute_orientation(dx :int, dy :int, flat : bool) -> int:
	if flat:
		if v: return Orientation.S if dy == 1 else Orientation.N
		else: return Orientation.S if dx == 1 else Orientation.N
	if dx == 1:
		if dy == 1: return Orientation.E
		else: return Orientation.E if v else Orientation.N
	else:
		if dy == 1: return Orientation.W if v else Orientation.S
		else: return Orientation.W

func _compute_contact(from : Vector2, to : Vector2, t : Vector2, o : int) -> Vector2:
	var dx : float = to.x - from.x
	var dy : float = to.y - from.y
	var n : float = float(IMAX) if dx == 0 else (dy / dx)
	var c : float = from.y - (n * from.x)
	if v:
		if o == Orientation.N: return Vector2(t.x, t.y - s)
		elif o == Orientation.S: return Vector2(t.x, t.y + s)
		elif o == Orientation.E:
			var x : float = t.x + dw
			return Vector2(x, from.y + n * (x - from.x))
		elif o == Orientation.W:
			var x : float = t.x - dw
			return Vector2(x, from.y + n * (x - from.x))
		else:
			var p : float = -m if (o == Orientation.SE or o == Orientation.NW) else m
			var k : float = t.y - p * t.x
			if o == Orientation.SE || o == Orientation.SW: k += s
			else: k -= s
			var x : float = (k - c) / (n - p)
			return Vector2(x, n * x + c)
	else:
		if o == Orientation.E: return Vector2(t.x + s, t.y)
		elif o == Orientation.W: return Vector2(t.x - s, t.y)
		elif o == Orientation.N:
			var y : float = t.y - dw
			return Vector2(from.x + (y - from.y) / n, y)
		elif o == Orientation.S:
			var y : float = t.y + dw
			return Vector2(from.x + (y - from.y) / n, y)
		else:
			var p : float = -im if (o == Orientation.SE or o == Orientation.NW) else +im
			var k : float = 0
			if o == Orientation.SW or o == Orientation.NW: k = t.y - (p * (t.x - s))
			else: k = t.y - (p * (t.x + s))
			var x : float = (k - c) / (n - p)
			return Vector2(x, n * x + c);

# compute as an Array, the Tiles that can be reached by a given Piece from a Tile given by it's col;row coordinates
# return the size of the built Array
func possible_moves(piece : Piece, from : Tile, tiles : Array) -> int:
	tiles.clear()
	if piece.get_mp() <= 0 or not is_on_map(from.coords): return 0
	var road_march_bonus : int = piece.road_march_bonus()
	search_count += 1
	from.parent = null
	from.acc = piece.get_mp()
	from.search_count = search_count
	from.road_march = road_march_bonus > 0
	stack.push_back(from)
	while(not stack.is_empty()):
		var src : Tile = stack.pop_back()
		if (src.acc + (road_march_bonus if src.road_march else 0)) <= 0: continue
		# warning-ignore:return_value_discarded
		_build_adjacents(src.coords)
		for dst in adjacents:
			if not dst.on_map: continue
			var o : int = to_orientation(angle(src, dst))
			var cost : int = piece.move_cost(src, dst, o)
			if (cost == -1): continue # impracticable
			var r : int = src.acc - cost
			var rm : bool = src.road_march and src.has_road(o)
			# not enough MP even with RM, maybe first move allowed
			if ((r + (road_march_bonus if rm else 0)) < 0 and not (src == from and piece.at_least_one_tile(dst))): continue
			if dst.search_count != search_count:
				dst.search_count = search_count
				dst.acc = r
				dst.parent = src
				dst.road_march = rm
				stack.push_back(dst)
				tiles.append(dst)
			elif (r > dst.acc or (rm and (r + road_march_bonus > dst.acc + (road_march_bonus if dst.road_march else 0)))):
				dst.acc = r
				dst.parent = src
				dst.road_march = rm
				stack.push_back(dst)
	return tiles.size()

# compute as an Array, the shortest path for a given Piece from a Tile to another given by there col;row coordinates
# return the size of the built Array
func shortest_path(piece : Piece, from : Tile,  to : Tile, tiles : Array) -> int:
	tiles.clear()
	if from == to or not is_on_map(from.coords) or not is_on_map(to.coords): return tiles.size()
	var road_march_bonus : int = piece.road_march_bonus()
	search_count += 1
	from.acc = 0
	from.parent = null
	from.search_count = search_count
	from.road_march = road_march_bonus > 0
	stack.push_back(from)
	while(not stack.is_empty()):
		var src : Tile = stack.pop_back()
		if (src == to): break
		# warning-ignore:return_value_discarded
		_build_adjacents(src.coords)
		for dst in adjacents:
			if not dst.on_map: continue
			var o : int = to_orientation(angle(src, dst))
			var cost : int = piece.move_cost(src, dst, o)
			if (cost == -1): continue # impracticable
			cost += src.acc
			var total : float  = cost + distance(dst.coords, to.coords)
			var rm : bool = src.road_march and src.has_road(o)
			if rm: total -= road_march_bonus
			var add : bool = false
			if dst.search_count != search_count:
				dst.search_count = search_count
				add = true
			elif dst.f > total or (rm and not dst.road_march and abs(dst.f - total) < 0.001):
				stack.erase(dst)
				add = true
			if add:
				dst.acc = cost
				dst.f = total
				dst.road_march = rm
				dst.parent = src
				var idx : int = IMAX
				for k in range(stack.size()):
					if stack[k].f <= dst.f:
						idx = k
						break
				if idx == IMAX: stack.push_back(dst)
				else: stack.insert(idx, dst)
	stack.clear()
	if to.search_count == search_count:
		var t : Tile = to
		while t != from:
			tiles.push_front(t)
			t = t.parent
		tiles.push_front(from)
	return tiles.size()

func range_of_influence(piece : Piece, from : Tile, category : int, tiles : Array) -> int:
	tiles.clear()
	var max_range : int = piece.max_range_of_fire(category, from)
	if not is_on_map(from.coords): return 0
	var tmp : Array = []
	search_count += 1
	from.search_count = search_count
	stack.push_back(from)
	while(not stack.is_empty()):
		var src : Tile = stack.pop_back()
		# warning-ignore:return_value_discarded
		_build_adjacents(src.coords)
		for dst in adjacents:
			if not dst.on_map: continue
			if dst.search_count == search_count: continue
			dst.search_count = search_count
			var d : int = int(distance(from.coords, dst.coords, false))
			if d > max_range: continue
			if line_of_sight(from.coords, dst.coords, tmp).x != -1: continue
			var o : int = distant_orientation(from, dst)
			dst.f = piece.volume_of_fire(category, d, from, o, dst, distant_opposite(o))
			stack.push_back(dst)
			tiles.append(dst)
	return tiles.size()
