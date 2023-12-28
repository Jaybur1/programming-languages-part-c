# University of Washington, Programming Languages, Homework 6, hw6runner.rb

# This is the only file you turn in, so do not modify the other files as
# part of your solution.

class MyPiece < Piece
  # The constant All_My_Pieces should be declared here
  All_My_Pieces = All_Pieces + [
    # Tailed cube piece -> □□
    #                      □□□
    rotations([[0, 0], [1, 0], [0, 1], [1, 1], [-1, 0]]),
    [ # Long piece-> □□□□□
      [[0, 0], [-1, 0], [-2, 0], [1, 0], [2, 0]],
      [[0, 0], [0, -1], [0, -2], [0, 1], [0, 2]]
    ],
    # Small corener piece -> □
    #                        □□
    rotations([[0, 0], [-1, 0], [0, -1]])
  ]
  # your enhancements here
  def self.next_piece board
    MyPiece.new(All_My_Pieces.sample, board)
  end
end

class MyBoard < Board
  # your enhancements here
  def initialize game
    super game
    @current_block = MyPiece.next_piece(self)
    @cheat_enabled = false
  end

  def next_piece
    if @cheat_enabled
      @current_block = MyPiece.new([[[0,0]]],self)
      @cheat_enabled = false
    else
      @current_block = MyPiece.next_piece(self)
    end
    @current_pos = nil
  end

  # Monkey patch the store_current method in order to handle the cheat block
  def store_current
    locations = @current_block.current_rotation
    displacement = @current_block.position
    # The hard coded 0..3 range  can break the game after the cheat block dropped due to nil on index 3,
    # the location size of the cheat block is 3, hance it is only up to index 2.
    # By changing the range to be op to locations.size - 1, it will ensure to have all index cases are covered.
    (0..(locations.size - 1)).each{|index|
      current = locations[index];
      @grid[current[1]+displacement[1]][current[0]+displacement[0]] =
      @current_pos[index]
    }
    remove_filled
    @delay = [@delay - 2, 80].max
  end

  def rotate_180_degrees
    if !game_over? and @game.is_running?
      @current_block.move(0,0,2)
    end
    draw
  end

  def cheat_block
    if !game_over? and @game.is_running? and @score >= 100 and !@cheat_enabled
      @cheat_enabled = true
      @score -= 100
    end
  end

  # extra cheat ;)
  def increase_score_by_100
    if !game_over? and @game.is_running?
      @score += 100
    end
  end
end

class MyTetris < Tetris
  # your enhancements here
  def set_board
    @canvas = TetrisCanvas.new
    @board = MyBoard.new(self)
    @canvas.place(@board.block_size * @board.num_rows + 3, @board.block_size * @board.num_columns + 6, 24, 80)

    @board.draw
  end
  def key_bindings
    super
    @root.bind('u', proc {@board.rotate_180_degrees})
    @root.bind('c', proc {@board.cheat_block})
    @root.bind('x', proc {@board.increase_score_by_100})
  end
end
