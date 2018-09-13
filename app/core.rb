require 'json'

path = File.expand_path('../../data/events/welcome-drinks-2018.json', __FILE__)
obj = JSON.parse(File.read(path))
print(obj)