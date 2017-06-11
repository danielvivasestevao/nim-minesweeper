import unittest
#Types
from main import Difficulty, Position, Square, Field
# Difficulties constants
from main import easy, advanced, pro
# procs
from main import parse_difficulty, create_square, create_field, to_char, print_field, get_surrounding_positions, initialize_field

suite "parse_difficulty test":

  setup:
    const
      ADVANCED = "aDVAnCed"
      PRO = "pRo"
      EASY = "eASy"
      GIBBERISH = "asdfghjkl"

  test "parse advanced":
    let advanced_difficulty = parse_difficulty(ADVANCED)
    require(advanced_difficulty == advanced)

  test "parse pro":
    let pro_difficulty = parse_difficulty(PRO)
    require(pro_difficulty == pro)

  test "parse easy":
    let easy_difficutly = parse_difficulty(EASY)
    require(easy_difficutly == easy)

  test "parse gibberish":
    let easy_difficutly = parse_difficulty(GIBBERISH)
    require(easy_difficutly == easy)


suite "create_square test":

  test "check values":
    let square: Square = create_square()
    require(square.hidden == true)
    require(square.mine == false)
    require(square.value == 0'u8)


suite "create_field test":

  setup:
    let
      easy_field = create_field(easy)
      advanced_field = create_field(advanced)
      pro_field = create_field(pro)

  test "check easy field length":
    require(uint8(easy_field.len) == easy.vertical)
    for i in 0..<easy_field.len:
      require(uint(easy_field[i].len) == easy.horizontal)

  test "check advanced field length":
    require(uint8(advanced_field.len) == advanced.vertical)
    for i in 0..<advanced_field.len:
      require(uint(advanced_field[i].len) == advanced.horizontal)

  test "check pro field length":
    require(uint8(pro_field.len) == pro.vertical)
    for i in 0..<pro_field.len:
      require(uint(pro_field[i].len) == pro.horizontal)

  test "check easy field contents":
    for i in 0..<easy_field.len:
      for j in 0..<easy_field[i].len:
        let square = easy_field[i][j]
        require(square.hidden == true)
        require(square.mine == false)
        require(square.value == 0)


suite "test get_surrounding_positions":

  setup:
    const easy_field = create_field(easy) # 9 * 9

  test "normal case":
    let pos: Position = (vertical: 5'u8, horizontal: 6'u8)
    let surrounding_positions =
      get_surrounding_positions(pos, easy_field)
    require(surrounding_positions.len == 8)

    require((
      (uint8(pos.vertical - 1), pos.horizontal) in surrounding_positions))
    require((
      (uint8(pos.vertical + 1), pos.horizontal) in surrounding_positions))    
    require((
      (pos.vertical, uint8(pos.horizontal - 1)) in surrounding_positions))
    require((
      (pos.vertical, uint8(pos.horizontal + 1)) in surrounding_positions))

    require((
      (uint8(pos.vertical - 1), uint8(pos.horizontal - 1)) in surrounding_positions))
    require((
      (uint8(pos.vertical - 1), uint8(pos.horizontal + 1)) in surrounding_positions))
    require((
      (uint8(pos.vertical + 1), uint8(pos.horizontal - 1)) in surrounding_positions))
    require((
      (uint8(pos.vertical + 1), uint8(pos.horizontal + 1)) in surrounding_positions))


  test "edge case 1":
    let pos: Position = (0'u8, 0'u8)
    let surrounding_positions =
      get_surrounding_positions(pos, easy_field)
    require(surrounding_positions.len == 3)
    require((0'u8, 1'u8) in surrounding_positions)
    require((1'u8, 1'u8) in surrounding_positions)
    require((1'u8, 0'u8) in surrounding_positions)

  test "edge case 2":
    let pos: Position = (8'u8, 8'u8)
    let surrounding_positions =
      get_surrounding_positions(pos, easy_field)
    require(surrounding_positions.len == 3)
    require((7'u8, 8'u8) in surrounding_positions)
    require((7'u8, 7'u8) in surrounding_positions)
    require((8'u8, 7'u8) in surrounding_positions)

  test "edge case 3":
    let pos: Position = (vertical: 5'u8, horizontal: 0'u8)
    let surrounding_positions =
      get_surrounding_positions(pos, easy_field)
    require(surrounding_positions.len == 5)

    require((
      (uint8(pos.vertical - 1), pos.horizontal) in surrounding_positions))
    require((
      (uint8(pos.vertical + 1), pos.horizontal) in surrounding_positions))    
    require((
      (pos.vertical, uint8(pos.horizontal + 1)) in surrounding_positions))

    require((
      (uint8(pos.vertical - 1), uint8(pos.horizontal + 1)) in surrounding_positions))
    require((
      (uint8(pos.vertical + 1), uint8(pos.horizontal + 1)) in surrounding_positions))



# suite "test initialize_field":

  # setup:
    # const easy_field = create_field(easy) # 9 * 9    

  # test "normal case":
    


suite "test to_char(uint8)":

  test "check normal cases":
    require(to_char(0'u8) == '0')
    require(to_char(1'u8) == '1')
    require(to_char(9'u8) == '9')

  test "expect exception for number > 9":
    expect OSError:
      discard to_char(10'u8)


suite "test to_char(Square)":

  setup:
    const
      HIDDEN = '?'
      MINE = '*'

  test "test hidden square":
    var square: Square = (hidden: true, mine: false, value: 0'u8)
    require(to_char(square) == HIDDEN)
    square.mine = true
    require(to_char(square) == HIDDEN)

  test "test mine square":
    var square: Square = (hidden: false, mine: true, value: 0'u8)
    require(to_char(square) == MINE)
    square = (true, true, 0'u8)
    require(to_char(square) == HIDDEN)    

  test "test value square":
    var square: Square = (hidden: false, mine: false, value: 0'u8)
    require(to_char(square) == '0')


suite "print_field":

  test "print_field":
    var field: Field = create_field(easy)
    initialize_field(field, (9'u8, 9'u8, 10'u8))
    for x in 0..<9:
      for y in 0..<9:
        field[x][y].hidden = false
    print_field(field)
