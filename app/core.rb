require 'json'
require 'rmagick'
include Magick

DATA_PATH = '../../data/'
EVENTS_PATH = 'events/'
OUTPUT_PATH = '../../output/'

path = File.expand_path(DATA_PATH + EVENTS_PATH + 'welcome-drinks-2018.json', __FILE__)
obj = JSON.parse(File.read(path))
print(obj)

f = Image.new(100, 100) { self.background_color = "white" }
f.write('test.png')

=begin def combine(imgs)
  all = ImageList.new(img[0], img[1]...)
  all.write('etc.png')
  exit
end
=end