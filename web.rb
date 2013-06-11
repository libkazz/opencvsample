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

use_original_name = false

def new_name(url)
  Digest::SHA1.hexdigest(url) + File.extname(url).downcase
end

def fit_name_350(name)
  name.sub(/(#{File.extname(name)})$/, "_350\\1")
end

def fit_name_600(name)
  name.sub(/(#{File.extname(name)})$/, "_600\\1")
end

def fit_name_face(name)
  name.sub(/(#{File.extname(name)})$/, "_face\\1")
end

get '/up' do
  user = params[:user]
  url = params[:url]
  #s3 = ::AWS::S3.new(
  #  access_key_id:     ENV["S3_ACCESS_KEY"],
  #  secret_access_key: ENV["S3_SECRET"]
  #)
  #bucket_name = "my-web-imags"
  #s3.buckets.create(bucket_name) unless s3.buckets[bucket_name].exists?
  #bucket = s3.buckets[bucket_name]
  #image_prefix = "images"
  image_name = use_original_name ? File.basename(url) : new_name(url)
  #image_path = File.join(image_prefix, user, image_name)
  #object_350 = bucket.objects[fit_name_350(image_path)]
  #bject_face = bucket.objects[fit_name_face(image_path)]

  open(url) do |sock|
    temp = Tempfile.open(image_name)
    temp.binmode
    temp.write(sock.read)

    #temp_image = Magick::Image.read(temp.path).first
    #temp_image.resize_to_fit!(350)
    #temp_image.write(fit_name_350(temp.path))
    #object_350.write(file: fit_name_350(temp.path), acl: :public_read, content_type: sock.content_type)

    #output = "images/temp.jpg" # opencv は tempfile の path のように拡張子以降に文字列が付くものを扱えない?
    image = EyeDetect.load(temp.path)
    image.eye_detect!
    image.write("public/temp.jpg")

    #object_face.write(file: output, acl: :public_read, content_type: sock.content_type)
  end
  #redirect object_face.public_url.to_s
  redirect "/temp.jpg"
end

