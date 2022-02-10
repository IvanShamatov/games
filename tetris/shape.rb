class Shape
  FORMS = {
    o: [["x","x"],
        ["x","x"]],

    z: [["x","x","."],
        [".","x","x"]],

    s: [[".","x","x"],
        ["x","x","."]],

    j: [["x",".","."],
        ["x","x","x"]],

    l: [["x","x","x"],
        ["x",".","."]],

    t: [[".","x","."],
        ["x","x","x"]],

    i: [["x","x","x","x"]]
  }

  COLORS = {
    o: Gosu::Color::CYAN,
    z: Gosu::Color::YELLOW,
    s: Gosu::Color::GREEN,
    j: Gosu::Color::RED,
    l: Gosu::Color::FUCHSIA,
    t: Gosu::Color::AQUA,
    i: Gosu::Color::BLUE
  }

  attr_reader :form, :color

  def initialize(shape)
    @form = FORMS[shape]
    @color = COLORS[shape]
  end

  def rotate
    @form = form.reverse.transpose
  end
end
