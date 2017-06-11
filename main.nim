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


# proc uncover(field: var Field, pos: Position):


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


