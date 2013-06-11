lib = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH << File.expand_path(lib)

require 'bundler/setup'
require 'sinatra'
require "sinatra/reloader" if development?
require 'haml'
require 'coffee-script'
require 'open-uri'
require 'fileutils'
require 'aws/s3'
require 'RMagick'
require 'opencv'
require 'awesome_print'
require 'debugger'
require 'eye_detect'
require 'glass_detect'

GLASSES = {
  nil  => "",
  773  => "http://dahpbpalpng0r.cloudfront.net/products/773_kadoya22-1/product/4057_1_front.jpg",
  2614 => "http://dahpbpalpng0r.cloudfront.net/products/2614_jill-stuart-05-0174-2/product/9957_4_front.jpg"
}

set :haml, {:format => :html5, :layout => :layout }

get '/image' do
  haml :image
end

get '/up' do
  @url = params[:url]
  @method = params[:method]
  @glass = params[:glass]

  open(@glass) do |sock|
    temp = Tempfile.open(File.basename(@glass))
    temp.binmode
    temp.write(sock.read)

    output = "public/glass.png"
    output_tmp = "public/glass_tmp.png"
    temp_image = Magick::Image.read(temp.path).first
    temp_image.resize_to_fit!(230)
    temp_image.write(output_tmp)
    image = GlassDetect.load(output_tmp)
    image.get_largest_contour
    image.write(output_tmp)
    `convert -fuzz 20% -transparent "#ffffff" #{output_tmp} #{output}`
  end if @glass && @glass != ""

  open(@url) do |sock|
    temp = Tempfile.open(File.basename(@url))
    temp.binmode
    temp.write(sock.read)

    output = "public/temp.jpg"
    temp_image = Magick::Image.read(temp.path).first
    temp_image.resize_to_fit!(350)
    temp_image.write(output)

    image = EyeDetect.load(output)
    image.send("#{@method}!") if image.respond_to?("#{@method}!")
    image.write(output)
  end
  haml :image
end

