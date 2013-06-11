lib = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH << File.expand_path(lib)

require 'bundler/setup'
require 'sinatra'
require "sinatra/reloader" if development?
require 'haml'
require 'coffee-script'
require 'open-uri'
require 'openssl'
require 'fileutils'
require 'aws/s3'
require 'RMagick'
require 'opencv'
require 'awesome_print'
require 'debugger'
require 'eye_detect'
require 'glass_detect'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
GLASSES = open("images/glasses.csv").readlines.inject({}){|h,line| name,url = line.strip.gsub(/"/,"").split(","); h.store(name, url); h}

set :haml, {:format => :html5, :layout => :layout }

get '/image' do
  @eye  = Struct.new(:center_x, :center_y).new
  @face = Struct.new(:left, :right, :width).new
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
    image.get_largest_contour!
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
    eyes = image.eye_detect
    left_eye  = eyes[0]
    right_eye = eyes[1]
    puts "eye[left: #{left_eye.inspect}, right: #{right_eye.inspect}]"
    @eye  = Struct.new(:center_x, :center_y).new
    @eye.center_x = (left_eye.center.x + right_eye.center.x) / 2
    @eye.center_y = (left_eye.center.y + right_eye.center.y) / 2
    @face = Struct.new(:left, :right, :width).new
    @face.left  = @eye.center_x - (@eye.center_x -  left_eye.center.x) * 2
    @face.right = @eye.center_x - (@eye.center_x - right_eye.center.x) * 2
    @face.width = @face.right - @face.left

    image.send("#{@method}!") if image.respond_to?("#{@method}!")
    image.write(output)
  end
  haml :image
end

