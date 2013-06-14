require 'sinatra/base'
require "sinatra/reloader"
require 'logger'
require 'haml'
require 'base64'
require 'coffee-script'
require 'open-uri'
require 'openssl'
require 'base64'
require 'fileutils'
require 'aws/s3'
require 'opencv'
require 'awesome_print'
require 'rmagick'
require 'debugger'
require_relative "lib/eye_detect"
require_relative "lib/glass_detect"
require_relative "models/glass"
require_relative "models/eyes"
require_relative "models/face"
require_relative "models/photo"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class Web < Sinatra::Application
  configure do
    set :haml, {:format => :html5, :layout => :layout }
    set :views, File.dirname(__FILE__) + '/views'
    set :public_folder, File.dirname(__FILE__) + '/public'

    $logger = Logger.new('logs/photo.log')
    $logger.level = Logger::DEBUG
  end

  configure :development do
    register Sinatra::Reloader
    also_reload "models/*.rb"
    also_reload "lib/*.rb"
  end

  get '/image' do
    url = params[:url]
    method = params[:method]

    if url
      @glass = Glass.find_by_id(params[:glass_id])
      @photo = Photo.new(url)
      @photo.download
      @photo.resize
      @eyes  = @photo.eyes
      @face  = @photo.face
      @photo.draw!(method)
      @eyes  = @photo.eyes
      @face  = @photo.face
    end

    haml :image
  end

  get '/capture' do
    haml :capture
  end

  post '/capture/upload' do
    image_str = params[:image]
    image_bin = Base64.decode64(image_str)
    File.open("upload.png", "wb") do |f|
      f.write(image_bin)
    end
    "saved"
  end

  post '/share' do
    image = params[:img]
    data = image.sub(/^data:image\/(png|jpg);base64,/, "")
    format = $1
    filename = Digest::SHA1.hexdigest(data) + ".#{format}"
    dir = File.join("public", "shared", Time.now.strftime("%Y%m%d"))
    path = File.join(dir, filename)
    FileUtils.mkdir_p(dir)
    open(path, "wb") do |f|
      f.write(Base64.decode64(data))
    end
    {src: URI.escape(path.sub("public", "")) }.to_json
  end
end
