require "bundler"
Bundler.require
require_relative "shape.rb"

WIDTH, HEIGHT = 700, 900
FIELD_OFFSET_X, FIELD_OFFSET_Y = 50, 50
NEXT_SHAPE_X, NEXT_SHAPE_Y = 500, 150
FIELD_WIDTH = 10
FIELD_HEIGHT = 20

SQUARE_SIDE = 40
MARGIN = 1

SHAPES = %i[o t z s j l i]

module ZOrder
  BACKGROUND, FIELD, SHAPE = *0..2
end

class Game < Gosu::Window

  attr_reader :field, :next_shape, :current_shape, :level, :points

  def initialize
    super(WIDTH, HEIGHT)
    self.caption = "Tetris"
    @text = Gosu::Font.new(30)
    reset_game
  end

  def reset_game
    @field = Array.new(FIELD_HEIGHT){ Array.new(FIELD_WIDTH) }
    @current_shape = Shape.new(SHAPES.sample)
    @shape_x, @shape_y = [(FIELD_WIDTH - current_shape.form[0].size) / 2 , 0]
    @next_shape = Shape.new(SHAPES.sample)
    @level = 1
    @points = 0
    @tick = 0
    @paused = false
    @gameover = false
  end

  def update
    exit if Gosu.button_down?(Gosu::KB_Q)
    on(Gosu::KB_W) { reset_game }

    @tick += 1
    @tick = 0 if @tick == 1000

    unless @paused || @gameover
      if cant_move_down?
        apply_shape_on_field
        clean_rows
        if can_add_shape?
          add_new_shape
        else
          gameover
        end
      end
      
      if @tick % 60 == 0
        move_down
      end

      on(Gosu::KB_DOWN) { unless @paused; move_down; end }
      on(Gosu::KB_UP) { unless @paused; rotate_shape; end }
      on(Gosu::KB_LEFT) { unless @paused; move_left; end }
      on(Gosu::KB_RIGHT) { unless @paused; move_right; end }
    end
    on(Gosu::KB_SPACE) { toggle_pause }
  end

  def on(key, &block)
    @on ||= {}
    @on[key] = block
  end

  def button_down(key)
    @pressed ||= []
    unless @pressed.include?(key) 
      @on[key]&.call
    end
    @pressed << key
  end

  def button_up(key)
    @pressed.delete(key)
  end

  def add_new_shape
    @current_shape = next_shape
    @next_shape = Shape.new(SHAPES.sample)
    @shape_x, @shape_y = [(FIELD_WIDTH - current_shape.form[0].size) / 2 , 0]
  end

  def cant_move_down?
    return true if @shape_y + current_shape.form.size >= FIELD_HEIGHT
    
    current_shape.form.each_with_index do |row, y|
      row.each_with_index do |tile, x|
        if (tile == 'x') && !(field[y + @shape_y+1][x + @shape_x].nil?)
          return true
        end        
      end
    end
    false 
  end

  def can_add_shape?
    shape_x, shape_y = [(FIELD_WIDTH - next_shape.form[0].size) / 2 , 0]
    next_shape.form.each_with_index do |row, y|
      row.each_with_index do |tile, x|
        if (tile == 'x') && !(field[y + shape_y][x + shape_x].nil?)
          return false
        end        
      end
    end
    true 
  end

  def gameover
    @gameover = true
  end

  def toggle_pause
    @paused = !@paused
  end

  def rotate_shape
    current_shape.rotate
    if (current_shape.form[0].size + @shape_x) > FIELD_WIDTH
      @shape_x = FIELD_WIDTH - current_shape.form[0].size
    end 
    if (current_shape.form.size + @shape_y) > FIELD_HEIGHT
      @shape_y = FIELD_HEIGHT - current_shape.form.size
    end 
  end

  def move_left
    return if @shape_x == 0
    return unless field[@shape_y][@shape_x - 1].nil?
    @shape_x -= 1
  end

  def move_right
    return if @shape_x == FIELD_WIDTH - current_shape.form[0].size
    return unless field[@shape_y][@shape_x + 1].nil?
    @shape_x += 1
  end

  def move_down
    return if @shape_y == FIELD_HEIGHT - current_shape.form.size
    @shape_y += 1
  end

  def apply_shape_on_field
    field.each_with_index do |row, y|
      row.each_with_index do |color, x|
        if current_shape.form.dig(y, x) == 'x'
          field[y + @shape_y][x + @shape_x] = current_shape.color
        elsif color
          field[y][x] = color
        else
          field[y][x] = nil
        end        
      end
    end
  end

  def clean_rows
    field.reject! { |row| row.all? {|tile| !tile.nil? } }
    rows = (FIELD_HEIGHT - field.size)
    return if rows.zero?
    add_points(rows)
    rows.times do
      field.unshift(Array.new(FIELD_WIDTH))
    end
  end

  def add_points(rows)
    points = [100, 300, 700, 1500][rows-1]
    @points += points
  end

  def draw
    draw_field(field, FIELD_OFFSET_X, FIELD_OFFSET_Y)
    draw_shape(
      current_shape, 
      FIELD_OFFSET_X + @shape_x * SQUARE_SIDE, 
      FIELD_OFFSET_Y + @shape_y * SQUARE_SIDE
    )
    draw_next_shape(next_shape, NEXT_SHAPE_X, NEXT_SHAPE_Y)
    @text.draw_text("Level ##{level}", 500, 50, 1, 1.0, 1.0, Gosu::Color::YELLOW)
    @text.draw_text("Points: #{points}", 500, 80, 1, 1.0, 1.0, Gosu::Color::YELLOW)
    @text.draw_text("Next shape:", 500, 110, 1, 1.0, 1.0, Gosu::Color::YELLOW)
    @text.draw_text("PAUSED", 200, 200, 1, 1.0, 1.0, Gosu::Color::WHITE) if @paused
    @text.draw_text("GAME OVER", 200, 200, 1, 1.0, 1.0, Gosu::Color::WHITE) if @gameover
  end

  def draw_next_shape(shape, offset_x, offset_y)
    shape.form.each_with_index do |row, y|
      row.each_with_index do |tile, x|
        color = tile == 'x' ? shape.color : Gosu::Color::BLACK
        draw_square(offset_x, offset_y, x, y, color, :no_border)
      end
    end
  end

  def draw_shape(shape, offset_x, offset_y)
    shape.form.each_with_index do |row, y|
      row.each_with_index do |tile, x|
        if tile == 'x' 
          color = shape.color
        else
          color = field[@shape_y+y][@shape_x+x]
          color = color || Gosu::Color::BLACK
        end
        draw_square(offset_x, offset_y, x, y, color, :no_border)
      end
    end
  end

  def draw_field(field, offset_x, offset_y)
    field.each_with_index do |row, y|
      row.each_with_index do |color, x|
        color ||= Gosu::Color::BLACK
        draw_square(offset_x, offset_y, x, y, color)
      end
    end
  end

  def draw_square(offset_x, offset_y, x, y, color, no_border = false)
    # border
    unless no_border
      Gosu.draw_rect(
        offset_x + x * SQUARE_SIDE,
        offset_y + y * SQUARE_SIDE,
        SQUARE_SIDE,
        SQUARE_SIDE,
        Gosu::Color::GRAY,
        ZOrder::FIELD
      )
    end
    # coloring insides
    Gosu.draw_rect(
      offset_x + x * SQUARE_SIDE + MARGIN,
      offset_y + y * SQUARE_SIDE + MARGIN,
      SQUARE_SIDE - MARGIN * 2,
      SQUARE_SIDE - MARGIN * 2,
      color,
      ZOrder::FIELD
    )
  end
end

Game.new.show
