require 'rmagick'
include Magick
require 'date'

require_relative 'data'
include Config
include JsonData

def createBlankImg(width, height, bg_col)
  Image.new(width, height) { self.background_color = bg_col }
end

def readImg(path)
  Magick::Image.read('assets/' + path).first
end

def tailOfString(str)
  arr = str.split(' ')
  arr.delete_at(0)
  arr.join(' ')
end

def drawText!(base, text, col, size=70, yOffset=30)
  t = Draw.new
  t.font_family = Config.getConfig()['font_name']
  t.pointsize = size
  t.gravity = CenterGravity
  #t.stroke = 'black'
  #t.stroke_width = 5

  # if string too long
  # split into two strings
  # draw other string w/ y offset
  metrics = t.get_type_metrics(text)
  if metrics.width > Config.getConfig['image_size'][0]
    drawText!(base, tailOfString(text), col, size, yOffset + 60)
    text = text.split(' ')[0]
  end

  t.annotate(base, 0, 0, 0, yOffset, text) { self.fill = col }
end

QUANT_MULT = 257

def arrToPixel(arr)
  Pixel.new(arr[0] * QUANT_MULT, arr[1] * QUANT_MULT, arr[2] * QUANT_MULT, 255)
end

def createEventImg(event_id)
  data = readJsonEvent(event_id)
  size = Config.getConfig()['image_size']

  catData = Config.getConfig()['categories'][data['category']]

  bg = nil
  bgData = data['bg']
  if bgData != nil && bgData != ''
    # image
    bg = readImg(data['bg'])
  else
    # just colour
    bg = createBlankImg(size[0], size[1], 'white')
  end

  icon = readImg(catData['icon'])
  icon.resize_to_fit!(size[0]/2, size[1]/2)
  bg.composite!(icon, NorthGravity, OverCompositeOp)
  drawText!(bg, data['name'], arrToPixel(catData['text']))
  bg.format = 'png'
  return bg
end

def createEventLabel(event_id)
  data = readJsonEvent(event_id)
  catData = Config.getConfig()['categories'][data['category']]

  size = Config.getConfig()['label_size']
  bg = createBlankImg(size[0], size[1], arrToPixel(catData['bg']))

  dateStr = DateTime.parse(data['date']).strftime('%e/%m')
  drawText!(bg, dateStr, 'black', 50, 5)
  bg.format = 'png'
  return bg
end

def addLabelToImg(img, label)
  list = Magick::ImageList.new
  list.from_blob(img.to_blob, label.to_blob)
  list.append(true)
end

# event img, & label below
def createEventFull(event_id)
  addLabelToImg(createEventImg(event_id), createEventLabel(event_id))
end

# stitches together full event images left -> right
def createWeek(week_id)
  data = JsonData.readJsonWeek(week_id)

  list = Magick::ImageList.new

  d = data['ids'].map { |x| createEventFull(x).to_blob }
  list.from_blob(*d)

  list.append(false)
end
createWeek('18-09-24').display 