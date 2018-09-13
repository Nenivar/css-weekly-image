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

def drawText!(base, text, col)
  t = Draw.new
  t.font_family = 'helvetica'
  t.pointsize = 52
  t.gravity = CenterGravity
  t.annotate(base, 0, 0, 0, 0, text) { self.fill = col }
end

QUANT_MULT = 257

def arrToPixel(arr)
  Pixel.new(arr[0] * QUANT_MULT, arr[1] * QUANT_MULT, arr[2] * QUANT_MULT, 255)
end

def createEventImg(event_id)
  data = readJsonEvent(event_id)
  size = Config.getConfig()['image_size']

  catData = Config.getConfig()['categories'][data['category']]

  f = createBlankImg(size[0], size[1], 'white')
  icon = readImg(catData['icon'])
  icon.resize_to_fit!(size[0]/2, size[1]/2)
  f.composite!(icon, CenterGravity, OverCompositeOp)
  drawText!(f, data['name'], arrToPixel(catData['text']))
  f.write('test.png')
end

#createEventImg('welcome-drinks-2018')
createEventImg('test-talk-2018')

=begin def combine(imgs)
  all = ImageList.new(img[0], img[1]...)
  all.write('etc.png')
  exit
end
=end