require 'rmagick'
include Magick

require_relative 'data'
include Config
include JsonData

def createBlankImg(width, height, bg_col)
  Image.new(width, height) { self.background_color = bg_col }
end

def readImg(path)
  Magick::Image.read('assets/' + path).first
end

def drawText!(base, text)
  t = Draw.new
  t.font_family = 'helvetica'
  t.pointsize = 52
  t.gravity = CenterGravity
  t.annotate(base, 0, 0, 0, 0, text)
end

def createEventImg(event_id)
  data = readJsonEvent(event_id)
  size = Config.getConfig()['image_size']

  catData = Config.getConfig()['categories'][data['category']]
  bg = catData['bg']

  f = createBlankImg(size[0], size[1], Pixel.new(bg[0], bg[1], bg[2], 255))
  icon = readImg(catData['icon'])
  icon.resize_to_fit!(size[0]/2, size[1]/2)
  f.composite!(icon, CenterGravity, OverCompositeOp)
  drawText!(f, data['name'])
  f.write('test.png')
end

createEventImg('welcome-drinks-2018')

=begin def combine(imgs)
  all = ImageList.new(img[0], img[1]...)
  all.write('etc.png')
  exit
end
=end