import sequtils
import strutils
import random


type
  Difficulty* = tuple[vertical: uint8, horizontal: uint8, mine_count: uint8]
  Position* = tuple[vertical: uint8, horizontal: uint8]
  Square* = tuple[hidden: bool, mine: bool, value: uint8]
  Field* = seq[seq[Square]]  # Field[row][column]

const
  easy*: Difficulty = (9'u8, 9'u8, 10'u8)
  advanced*: Difficulty = (16'u8, 16'u8, 40'u8)
  pro*: Difficulty = (16'u8, 30'u8, 99'u8)


## Convert a string to a Difficulty. If the string does not conform
## to any Difficulty, return easy.
proc parse_difficulty*(input: string): Difficulty =
  let input_low = input.toLowerAscii()
  if input_low == "advanced":
    result = advanced
  elif input_low == "pro":
    result = pro
  else:
    result = easy


## Create a standard square: Hidden, no mine, 0
proc create_square*(): Square =
  result = (true, false, 0'u8)


## Create a field with all Squares set to
## (hidden: true, mine: false, value: 0)
proc create_field*(difficulty: Difficulty): Field =
  result = newSeq[seq[Square]](difficulty.vertical)
  for i in 0..<difficulty.vertical:
    result[int(i)] = newSeq[Square](difficulty.horizontal)
    for j in 0..<difficulty.horizontal:
      result[int(i)][int(j)] = create_square()


## Get all vertical, horizontal and diagonal neighbouring positions of a position.
proc get_surrounding_positions*(position: Position, field: Field): seq[Position] =
  if field.len <= 0:
    return @[]
  result = @[]
  for x in -1..1:
    for y in -1..1:
      if not ((x == 0) and (y == 0)):
        let x_coord = int(position.horizontal) + x
        let y_coord = int(position.vertical) + y
        if (x_coord in 0..<field.len) and (y_coord in 0..<field[0].len):
          result.add((vertical: uint8(y_coord), horizontal: uint8(x_coord)))


## Get all vertical and horizontal neighbouring positions of a position.
proc get_connected_positions*(position: Position, field: Field): seq[Position] =
  if field.len <= 0:
    return @[]
  result = @[]
  for x in @[-1, 1]:
    if int(position.vertical) + x >= 0 and int(position.vertical) + x < field.len:
      result.add((uint8(int(position.vertical) + x), position.horizontal))
    if int(position.horizontal) + x >= 0 and int(position.horizontal) + x < field[0].len:
      result.add((position.vertical, (uint8(int(position.horizontal) + x))))


## Set mines randomly and update surrounding fields
proc initialize_field*(field: var Field, difficulty: Difficulty) {.discardable.} =
  if int(difficulty.mine_count) > (field.len * field[0].len):
    raise newException(OSError, "Cannot have more mines than squares on the field")
  var mine_fields: seq[tuple[vertical: uint8, horizontal: uint8]] = @[]
  while mine_fields.len < int(difficulty.mine_count):
    let rand_vert = uint8(random(int(difficulty.vertical)))
    let rand_hori = uint8(random(int(difficulty.horizontal)))
    let mine_field = (vertical: rand_vert, horizontal: rand_hori)
    if (not (mine_field in mine_fields)):
      mine_fields.add(mine_field)
      # set as mine field
      field[int(mine_field.vertical)][int(mine_field.horizontal)].mine = true
      # update surrounding values
      for f in get_surrounding_positions(mine_field, field):
        field[int(f.vertical)][int(f.horizontal)].value += 1


proc find_connected_zero_squares*(field: Field, pos: Position, seen_positions: var seq[Position]): seq[Position] =
  result = @[]
  for connected_position in get_connected_positions(pos, field):
    if not (connected_position in seen_positions):
      seen_positions.add(connected_position)
      let square = field[int(connected_position.vertical)][int(connected_position.horizontal)]
      if square.value == 0:
        result.add(connected_position)
        result.add(find_connected_zero_squares(field, connected_position, seen_positions))


proc find_connected_zero_squares*(field: Field, pos: Position): seq[Position] =
  var seen_positions: seq[Position] = @[]
  return find_connected_zero_squares(field, pos, seen_positions)


## Set all squares with value=0 which are connected to the given position to hidden=false.
## Set all squares surrounding any of the uncovered value=0 squares to hidden=false.
proc uncover*(field: var Field, pos: Position) {.discardable.} =
  let zero_square_positions = find_connected_zero_squares(field, pos)
  var uncovered_positions: seq[Position] = @[]
  for zero_square_position in zero_square_positions:
    field[int(zero_square_position.vertical)][int(zero_square_position.horizontal)].hidden = false
    uncovered_positions.add(zero_square_position)
    for surrounding_position in get_surrounding_positions(zero_square_position, field):
      let cur_square_value = field[int(surrounding_position.vertical)][int(surrounding_position.horizontal)].value
      if not ((cur_square_value == 0) or (surrounding_position in uncovered_positions)):
        field[int(surrounding_position.vertical)][int(surrounding_position.horizontal)].hidden = false
        uncovered_positions.add(surrounding_position)

proc to_char*(value: uint8): char =
  let value_str = $(value)
  if value > 9'u8:
    raise newException(OSError, "Cannot turn $1 into a char" % [value_str])
  else:
    result = value_str[0]


## Display a Square as a string depending on its state.
proc to_char*(square: Square): char =
  if square.hidden:
    result = '?'
  elif square.mine:
    result = '*'
  else:
    result = to_char(square.value)


proc print_field*(field: Field) {.discardable.} =
  for row in field:
    echo row.map(to_char)
      

# main
# echo "Input difficulty"
# let d: Difficulty = parse_difficulty(readLine(stdin))
# echo repr(d)


