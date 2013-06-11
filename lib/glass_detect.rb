class GlassDetect
  include OpenCV

  def self.load(input)
    new(input)
  end

  def initialize(input)
    @input = input
    @image = CvMat.load(@input)
    @gray = OpenCV.BGR2GRAY(@image)
    @gray.equalize_hist
  end

  def debug?
    @debug
  end

  def get_largest_contour
    canny = @gray.canny(50, 150)
    contour = canny.find_contours(mode: CV_RETR_LIST, method: CV_CHAIN_APPROX_SIMPLE)

    largest = nil
    while contour
      unless contour.hole?
        box = contour.bounding_rect
        largest ||= box
        largest = box if box.width > largest.width
      end
      contour = contour.h_next
    end
    largest_rect = [largest.x, largest.y, largest.width, largest.height]

    @image = IplImage.load(@input);
    @image = @image.set_roi(CvRect.new(*largest_rect))
  end

  def write(output)
    @image.save_image(output)
  end
end

if __FILE__ == $0 && ARGV.length == 2
  require 'bundler/setup'
  require 'opencv'
  image = GlassDetect.load(ARGV[0])
  image.get_lagest_contour
  image.write(ARGV[1])
  `open ARGV[1]`
end


