class Level
  def self.start(id)
    level = new(LEVELS[id].split("\n")[1..-1])
    level.setup_map
    level
  end

  def setup_map
    @height = data.size
    @width = data.max_by(&:size).size
    @data.each_with_index do |row, y|
      @width.times do |x|
        case row[x]
        when 'X'
          @walls << Wall.new(x, y)
          @map[y][x] = Wall.new(x, y)
        when '.'
          @goals << Goal.new(x, y)
          @map[y][x] = Goal.new(x, y)
        when '*'
          @boxes << Box.new(x, y)
          @map[y][x] = Box.new(x, y)
        when '@'
          @player = Player.new(x, y)
          @map[y][x] = Player.new(x, y)
        else
          @map[y][x] = Space.new(x, y)
        end
      end
    end
  end

  def initialize(data)
    @data = data
    @width, @height = nil, nil
    @map = []
    @walls = []
    @goals = []
    @player = nil
    @boxes = []
  end

  def draw
  end
end
