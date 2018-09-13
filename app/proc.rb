require 'rmagick'
include Magick



f = Image.new(500, 500) { self.background_color = "white" }
icon = Magick::Image.read("assets/icons/social.png").first
icon.resize_to_fit!(50, 100)
f.composite(icon, CenterGravity, OverCompositeOp).write('test.png')

#text = 'dog'
#t = Draw.new
#t.font_family = 'helvetica'
#t.pointsize = 52
#t.gravity = CenterGravity

=begin def combine(imgs)
  all = ImageList.new(img[0], img[1]...)
  all.write('etc.png')
  exit
end
=end