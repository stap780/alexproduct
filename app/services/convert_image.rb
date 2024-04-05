class ConvertImage
  require "image_processing/mini_magick"

  attr_reader :image_path, :background, :size, :temp_image_path

  def initialize(image, background, size, options={})
    # host = Rails.env.development? ? 'http://localhost:3000' : 'http://95.163.236.170'
    # img_link = host+Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)

    puts "initialize ConvertImage"
    @image_path = ActiveStorage::Blob.service.path_for(image.key) #image
    @start_image_png = "#{Rails.root}/public/convert/start_image.png"
    @start_image_jpg = "#{Rails.root}/public/convert/start_image.jpg"
    @background = background
    @size = size
    @temp_image_path = "#{Rails.root}/public/convert/temp_image.jpg"
    @options = options
  end

  def convert_to_jpg
    image = MiniMagick::Image.open(@image_path)
    image.format "jpg"
    image.write @start_image_jpg
  end

  def convert_to_png
    image = MiniMagick::Image.open(@image_path)
    image.format "png"
    image.write @start_image_png
  end

  def transparent_background
    puts "transparent_background start"
    convert_to_png
    # convert test.jpg -fill 'transparent' -fuzz 20% -draw 'color 0,0 floodfill' output.png
    convert = MiniMagick::Tool::Convert.new
    convert << @start_image_png
    convert.merge! ["-fill", "transparent", "-fuzz", "20%", "-draw", "color 0,0 floodfill"]
    convert.format('png')
    convert << @temp_image_path
    puts "convert => "+convert.to_s
    puts "transparent_background finish"
  end

  def change_background_for_png
    puts "color_background start"
    # convert output.png -fuzz 0% -fill red -opaque transparent -flatten result1.png - работает на локале
    convert = MiniMagick::Tool::Convert.new
    convert << @temp_image_path
    convert.merge! ["-fuzz", "0%", "-fill", @background, "-opaque", "transparent", "-flatten"]
    convert << @temp_image_path
    convert.call
    puts "color_background finish"
  end

  def change_background_for_jpg #это сразу удаляет фон и ставит новый фон for jpg
    puts "change_background start"
    convert_to_jpg
    # convert test.jpg -fuzz 25% -fill none -draw "alpha 0,0 floodfill" -background red -flatten result2.jpg - сработало на продакшене
    convert = MiniMagick::Tool::Convert.new
    convert << @start_image_jpg
    convert.merge! ["-fuzz", "25%", "-fill", "none", "-draw", "alpha 0,0 floodfill", "-background", @background, "-flatten"]
    convert << @temp_image_path
    convert.call
    puts "change_background finish"
  end

  def resize
    puts "resize start"
    # convert output.png -fuzz 0% -fill red -opaque transparent -flatten result1.png
    convert = MiniMagick::Tool::Convert.new
    convert << @temp_image_path
    convert.merge! ["-resize", @size]
    convert << @temp_image_path
    convert.call
    puts "resize finish"
  end


  def multi_changes_for_jpg
    puts "multi_changes_for_jpg start"
    convert_to_jpg
    convert = MiniMagick::Tool::Convert.new
    convert << @start_image_jpg
    @options.each do |key, val|
      convert << "#{key}" << "#{val}"
    end
    convert << @temp_image_path
    convert.call
    puts "multi_changes_for_jpg finish"
  end

  def close
    FileUtils.rm_rf(Dir.glob("#{Rails.root}/public/convert/*"))
  end

end


# convert '/Users/administrator/Documents/rails_projects/alexproduct/public/test.jpg' 
# -resize 300x300 -negate -rotate 90 '/Users/administrator/Documents/rails_projects/alexproduct/public/convert/temp_image.jpg'