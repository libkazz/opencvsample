class EyeDetect
  include OpenCV

  METHODS = %w(gray binary adaptive_binary canny contours hough_line eye_detect face_detect)

  def self.load(input)
    new(input)
  end

  def initialize(input)
    @input = input
    @image = CvMat.load(@input)
  end

  def gray
    @gray = OpenCV.BGR2GRAY(@image)
    @gray.equalize_hist
    @gray
  end

  def binary
    gray.threshold(0x55, 0xFF, CV_THRESH_BINARY)
  end

  def adaptive_binary
    params = {
      threshold_type: CV_THRESH_BINARY,
      adaprive_method: CV_ADAPTIVE_THRESH_MEAN_C,
      block_size: 7,
      param1: 3
    }
    gray.adaptive_threshold(0xFF, params)
  end

  def canny
    gray.canny(50, 150)
  end

  def contours!
    contour = canny.find_contours(mode: CV_RETR_LIST, method: CV_CHAIN_APPROX_SIMPLE)

    while contour
      unless contour.hole?
        box = contour.bounding_rect
        @image.rectangle! box.top_left, box.bottom_right, color: CvColor::Blue
      end
      contour = contour.h_next
    end
  end

  def hough_line!
    # mehtod, 距離分解能, 角度分解能, 閾値
    # 線分の最小長さ, 2点が同一線分上にあると見なす場合に許容される最大距離
    seq = canny.hough_lines(CV_HOUGH_STANDARD, 1, Math::PI/180, 70, 0, 0)
    seq.each do |line|
      a = Math.cos(line.theta)
      b = Math.sin(line.theta)
      x0 = a * line.rho
      y0 = b * line.rho

      p1 = CvPoint.new(x0 + 1000 * (-b), y0 + 1000 * a)
      p2 = CvPoint.new(x0 - 1000 * (-b), y0 - 1000 * a)

      @image.line! p1, p2, color: CvColor::Blue
    end
  end

  def eye_detect
    file = "/usr/local/share/OpenCV/haarcascades/haarcascade_eye.xml"
    detector = CvHaarClassifierCascade::load(file)

    puts "Detecting: #{detector}"
    detect_params = {
      scale_factor: 1.2,            # 縮小スケール
      min_neighbors: 3,             # 最低矩形数
      min_size: CvSize.new(10,10)   # 最小矩形
    }
    eyes = detector.detect_objects(gray, detect_params)
    raise "Cannot detect eyes enough" if eyes.size < 2
    if eyes.size > 2
      # 高さが平均値に近い順に選択する
      eye_y_avg = eyes.inject(0){|sum, e| sum += e.center.y} / eyes.count
      eyes = eyes.sort_by{|e| (e.center.y - eye_y_avg).abs }[0..1]
    end
    eyes.sort_by{|e| e.center.x }
  end

  def eye_detect!
    eye_detect.each do |region|
      @image.circle!(region.center, (region.width + region.height)/4, color: CvColor::Blue, line_type: :aa)
    end
  end

  def face_detect!
    file = "/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_alt.xml"
    # この分類器だと検出できないケースが多い
    #file = "/usr/local/share/OpenCV/haarcascades/haarcascade_profileface.xml"
    detector = CvHaarClassifierCascade::load(file)

    regions = []
    puts "Detecting: #{detector}"
    detect_params = {
      scale_factor: 1.1,            # 縮小スケール
      min_neighbors: 2,             # 最低矩形数
      min_size: CvSize.new(30,30)   # 最小矩形
    }
    detector.detect_objects(gray, detect_params).each do |region|
      puts "Detect: #{region}"
      color = CvColor::Blue
      regions << region
      @image.rectangle!(region.top_left, region.bottom_right, color: color, line_type: :aa)
    end
  end

  METHODS.each do |m|
    bang_method = "#{m}!"
    unless method_defined?(bang_method)
      define_method(bang_method) do
        @image = send(m)
      end
    end
  end

  def write(output)
    @image.save_image(output)
  end
end

if __FILE__ == $0 && ARGV.length == 2
  require 'bundler/setup'
  require 'opencv'
  image = EyeDetect.load(ARGV[0])
  image.eye_detect!
  image.write(ARGV[1])
  `open ARGV[1]`
end

