lib = File.join(File.dirname(__FILE__), 'lib')
$LOAD_PATH << File.expand_path(lib)

require 'bundler/setup'
require 'sinatra'
require "sinatra/reloader" if development?
require 'haml'
require 'open-uri'
require 'fileutils'
require 'aws/s3'
require 'RMagick'
require 'opencv'
require 'awesome_print'
require 'debugger'
require 'eye_detect'

set :haml, {:format => :html5 }

get '/image' do
  haml :image
end

get '/up' do
  @url = params[:url]
  @method = params[:method]

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

