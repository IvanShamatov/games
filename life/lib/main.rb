WINDOW_WIDTH, WINDOW_HEIGHT = 1200, 800
FIELD_HEIGHT, FIELD_WIDTH = 80, 120
SQUARE_SIDE = 10
MARGIN = 1
LIVE, DEAD = 1, 0

class Game < Gosu::Window
  attr_accessor :field, :next_field, :drawing

  def initialize
    super(WINDOW_WIDTH, WINDOW_HEIGHT)
    self.caption = "Life"
    @field = Array.new(FIELD_HEIGHT){ Array.new(FIELD_WIDTH) }
    @next_field = Array.new(FIELD_HEIGHT){ Array.new(FIELD_WIDTH) }
    @drawing = Array.new(FIELD_HEIGHT){ Array.new(FIELD_WIDTH) }
    @tick = 0
    #init
  end
  
  def update
    if button_down?(Gosu::MS_LEFT)
      y, x = mouse_y / 10, mouse_x / 10
      @drawing[y][x] = LIVE
    end
  
    recalculate
    @tick += 1
  end

  # def button_down(key)
  # end

  def button_up(key)
    if key == Gosu::MS_LEFT
      drawing.each_with_index do |row, y|
        row.each_with_index do |cell, x|
          if cell == LIVE
            @field[y][x] = LIVE
          end
        end
      end       
    end
  end

  def init
    field.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        @field[y][x] = [LIVE, DEAD].sample
      end
    end    
  end
    
  # в пустой (мёртвой) клетке, рядом с которой ровно три живые клетки, зарождается жизнь;
  # если у живой клетки есть две или три живые соседки, то эта клетка продолжает жить; 
  # в противном случае, если соседей меньше двух или больше трёх, клетка умирает («от одиночества» или «от перенаселённости»)
  def recalculate
    field.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        cells_around = [
          field.dig(y-1, x-1), field.dig(y-1, x), field.dig(y-1, x+1),
          field.dig(y, x-1),   field.dig(y, x+1),
          field.dig(y+1, x-1), field.dig(y+1, x), field.dig(y+1, x+1)          
        ]
        live_cells = cells_around.count { _1 == LIVE }
        
        if cell == DEAD && live_cells == 3
          next_field[y][x] = LIVE
        elsif cell == LIVE && [2, 3].include?(live_cells)
          next_field[y][x] = LIVE
        else
          next_field[y][x] = DEAD
        end
      end
    end
    @field, @next_field = @next_field, Array.new(FIELD_HEIGHT){ Array.new(FIELD_WIDTH) }
  end
  
  def draw
    field.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        color = (cell == LIVE) ? Gosu::Color::GREEN : Gosu::Color::WHITE
        draw_square(x, y, color)
      end
    end
    drawing.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        draw_square(x, y, Gosu::Color::GREEN) if cell == LIVE
      end
    end
  end

  def draw_square(x, y, color)
    Gosu.draw_rect(
      x * SQUARE_SIDE,
      y * SQUARE_SIDE,
      SQUARE_SIDE,
      SQUARE_SIDE,
      Gosu::Color::GRAY
    )
    Gosu.draw_rect(
      x * SQUARE_SIDE + MARGIN,
      y * SQUARE_SIDE + MARGIN,
      SQUARE_SIDE - MARGIN * 2,
      SQUARE_SIDE - MARGIN * 2,
      color
    )
  end
end