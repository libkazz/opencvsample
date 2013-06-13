class Face
  attr_reader :left, :right, :width

  def initialize
    @left  = 0
    @right = 0
    @width = 0
  end

  def detect(eyes)
    width_per_pd = 2.0
    @left  = eyes.center_x - (eyes.center_x -  eyes.left_eye.center.x) * width_per_pd
    @right = eyes.center_x - (eyes.center_x - eyes.right_eye.center.x) * width_per_pd
    @width = right - left

    $logger.debug self
    self
  end

  def inspect
    "<Face: left: #{@left.round(2)}, right: #{@right.round(2)}, width: #{@width.round(2)}>"
  end
end

