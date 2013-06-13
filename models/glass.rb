class Glass
  GLASSES = \
    open("images/glasses.csv").
    readlines.inject([]){|a,line|
      name, url = line.strip.gsub(/"/,"").split(",")
      a << [name, url]
      a
    }

  class << self
    def find_by_id(id)
      name, image_url = GLASSES[id.to_i - 1]
      rerutn nil unless name
      glass = new(id, name, image_url)
      glass.download
      glass.transparent

      $logger.debug glass
      glass
    end

    def all
      GLASSES.map.with_index{|(name, src),i| new(i+1, name, src) }
    end
  end

  attr_reader :id, :name, :image_url, :filename, :original_path, :overlay_path

  def initialize(id, name, image_url)
    @id   = id
    @name = name
    @image_url = image_url
    @filename  = "#{@id}.png"
  end

  def inspect
    "<Glass: id: #{id}, name: #{name}, src: #{src}>"
  end

  def src
    overlay_path.sub("public", "")
  end

  def original_path
    File.join("images/glasses/original", filename)
  end

  def overlay_path
    File.join("public/glasses/overlay", filename)
  end

  def download
    $logger.debug "Glass#download: #{image_url}, to: #{original_path}"
    return if File.exist?(original_path)

    FileUtils.mkdir_p(File.dirname(original_path))
    open(image_url) do |sock|
      open(original_path, "wb"){|io| io << sock.read }
    end
  end

  def transparent
    $logger.debug "Glass#transparent: #{original_path}, to: #{overlay_path}"
    return if File.exist?(overlay_path)

    FileUtils.mkdir_p(File.dirname(overlay_path))
    mini = original_path.sub(".png", "-mini.png")
    image = GlassDetect.load(original_path)
    image.get_largest_contour!
    image.write(mini)
    `convert -fuzz 20% -transparent "#ffffff" #{mini} #{overlay_path}`
    FileUtils.rm(mini)
  end
end
