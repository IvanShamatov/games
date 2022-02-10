require_relative 'levels.rb'
require_relative 'tile.rb'
require_relative 'level.rb'
require_relative 'player.rb'

WINDOW_WIDTH, WINDOW_HEIGHT = 1000, 800

module Z
  BACKGROUND, MAP, PLAYER = *[0, 1, 2]
end

class StateManager
  def initialize
    @state = :menu
    @passed_level = []
  end

  def menu
  end

  def level
  end

  def update
  end

  def draw
  end
end


class Game < Gosu::Window
  def initialize
    super WINDOW_WIDTH, WINDOW_HEIGHT
    self.caption = "Sokoban"
    @background_image = Gosu::Image.new("media/background.png", tileable: true)
    @state = StateManager.new
  end
  
  def update
    @state.update
  end
  
  def draw
    @state.draw
    draw_background
    binding.pry
  end

  def draw_background
    @bg_height ||= @background_image.height
    @bg_width ||= @background_image.width
    @bg_rows ||= (WINDOW_HEIGHT / @bg_height.to_f).ceil
    @bg_cols ||= (WINDOW_WIDTH / @bg_width.to_f).ceil
    @bg_rows.times do |j|
      @bg_cols.times do | i|
        @background_image.draw(i * @bg_width, j * @bg_height, Z::BACKGROUND)
      end
    end
  end
end