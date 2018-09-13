require 'rmagick'
include Magick

def createBlankImg(width, height, bg_col)
  Image.new(width, height) { self.background_color = bg_col }
end

def readImg(path)
  Magick::Image.read("assets/icons/social.png").first
end

def drawText!(base, text)
  t = Draw.new
  t.font_family = 'helvetica'
  t.pointsize = 52
  t.gravity = CenterGravity
  t.annotate(base, 0, 0, 0, 0, text)
end

def createEventImg(event_id)
  f = createBlankImg(500, 500, 'white')
  icon = readImg("assets/icons/social.png")
  icon.resize_to_fit!(50, 100)
  g = f.composite(icon, CenterGravity, OverCompositeOp)
  drawText!(g, 'dog')
  g.write('test.png')
end

createEventImg('dog')

=begin def combine(imgs)
  all = ImageList.new(img[0], img[1]...)
  all.write('etc.png')
  exit
end
=end