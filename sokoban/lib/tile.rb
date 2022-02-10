class Tile
  def initialize(x, y, movable = false, collidable = false)
    @x, @y = x, y
    @movable = movable
    @collidable = collidable
  end

  def movable?
    @movable
  end

  def collidable?
    @collidable
  end
end

class Space < Tile
  def initialize(x, y)
    super(x, y)
  end
end

class Wall < Tile
  def initialize(x, y)
    super(x, y)
    @movable = false
    @collidable = true
  end
end

class Goal < Tile
  def initialize(x, y)
    super(x, y)
    @movable = false
    @collidable = false
  end
end

class Box < Tile
  def initialize(x, y)
    super(x, y)
    @movable = true
    @collidable = true
  end
end
