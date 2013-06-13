class Eyes
  attr_reader :center_x, :center_y, :left_eye, :right_eye

  def initialize
    @center_x  = 0
    @center_y  = 0
  end

  def detect(cv)
    eyes = cv.eye_detect

    @left_eye  = eyes[0]
    @right_eye = eyes[1]
    @center_x  = (left_eye.center.x + right_eye.center.x) / 2
    @center_y  = (left_eye.center.y + right_eye.center.y) / 2

    $logger.debug self
    self
  end

  def inspect
    "<Eyes: center_x: #{@center_x.round(2)}, center_y: #{@center_y.round(2)}>"
  end
end
