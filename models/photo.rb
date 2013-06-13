class Photo
  attr_reader :filename, :image_url

  def initialize(image_url)
    @image_url = image_url
    @filename  = Digest::SHA1.hexdigest(image_url) + ".jpg"
  end

  def inspect
    "<Photo: src: #{src}>"
  end

  def cv
    @cv ||= EyeDetect.load(resized_path)
  end

  def src
    drawed_path.sub("public", "")
  end

  def original_path
    File.join("images/photos/original", Time.now.strftime("%Y%m"), filename)
  end

  def resized_path
    File.join("images/photos/resized", Time.now.strftime("%Y%m"), filename)
  end

  def drawed_path
    File.join("public/photos/drawed", Time.now.strftime("%Y%m"), filename)
  end

  def eyes
    @eyes ||= Eyes.new.detect(cv)
  end

  def face
    @face ||= Face.new.detect(eyes)
  end

  def draw!(method)
    $logger.debug "Photo#draw: method: #{method}, from: #{resized_path}, to: #{drawed_path}"

    FileUtils.mkdir_p(File.dirname(drawed_path))
    cv.send("#{method}!") if cv.respond_to?("#{method}!")
    cv.write(drawed_path)
  end

  def download
    $logger.debug "Photo#download: #{image_url}, to: #{original_path}"
    return if File.exist?(original_path)

    FileUtils.mkdir_p(File.dirname(original_path))
    open(image_url) do |sock|
      open(original_path, "wb"){|io| io << sock.read}
    end
  end

  def resize
    $logger.debug "Photo#resize: #{original_path}, to: #{resized_path}"
    return if File.exist?(resized_path)

    FileUtils.mkdir_p(File.dirname(resized_path))
    image = Magick::Image.read(original_path).first
    image.resize_to_fit!(350)
    image.write(resized_path)
  end
end
