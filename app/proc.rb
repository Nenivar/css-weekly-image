require 'rmagick'
include Magick
require 'date'

require_relative 'data'
include Config
include JsonData

# image
module Processing
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

  def drawText!(base, text, col, size=65, xOffset=0, yOffset=30, stroke=false, anchor=CenterGravity)
    t = Draw.new
    t.font_family = Config.getConfig()['font_name']
    t.pointsize = size
    t.gravity = anchor
    if stroke
      t.stroke = 'black'
      t.stroke_width = 10
      stroke_antialias = true
      #t.stroke_antialias = true
    end

    # if string too long
    # split into two strings
    # draw other string w/ y offset
    metrics = t.get_type_metrics(text)
    if metrics.width > Config.getConfig['image_size'][0]
      drawText!(base, tailOfString(text), col, size, xOffset, yOffset + 60, stroke)
      text = text.split(' ')[0]
    end

    t.annotate(base, 0, 0, xOffset, yOffset, text) { self.fill = col }
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

    icon = readImg(getIconForEvent(data))
    icon.resize_to_fit!(size[0]/2, size[1]/2)
    bg.composite!(icon, NorthGravity, OverCompositeOp)

    drawText!(bg, data['name'], getTextColForEvent(data), 65, 4, 30, true)
    drawText!(bg, data['name'], getTextColForEvent(data))

    bg.format = 'png'

    return bg
  end

  def getTextColForEvent(event_data)
    return event_data['text'] == nil ? 'black' : arrToPixel(event_data['text'])
  end

  def getIconForEvent(event_data)
    return event_data['icon'] == nil ? getCategoryForEvent(event_data)['icon'] : event_data['icon']
  end

  def getCategoryForEvent(event_data)
    return Config.getConfig()['categories'][event_data['category']]
  end

  def createEventLabel(event_id)
    data = readJsonEvent(event_id)
    catData = Config.getConfig()['categories'][data['category']]

    size = Config.getConfig()['label_size']
    bg = createBlankImg(size[0], size[1], arrToPixel(catData['bg']))

    dateStr = DateTime.parse(data['date']).strftime('%e/%m')
    drawText!(bg, dateStr, arrToPixel(catData['text']), 40, 0, 5)
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

  def createHeader(week_id)
    data = JsonData.readJsonWeek(week_id)

    width = data['ids'].length * getConfig()['image_size'][0]
    height = getConfig()['header_height']
    bg = createBlankImg(width, height, arrToPixel([25, 26, 25]))

    icon = readImg(getConfig()["css_icon"])
    icon.resize_to_fit!(width/2, height/2)
    bg.composite!(icon, WestGravity, 20, 0, OverCompositeOp)

    # TODO: not this :(
    t = Draw.new
    t.font_family = Config.getConfig()['font_name']
    t.pointsize = 45
    t.gravity = EastGravity
    t.annotate(bg, 0, 0, 20, 7, 'Week 0') { self.fill = 'white' }
    bg.format = 'png'

    drawText!(bg, 'Events', 'white', 60, 0, 7)

    return bg
  end

  def createFullImg(week_id)
    addLabelToImg(createHeader(week_id), createWeek(week_id))
  end
end