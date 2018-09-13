require 'json'

module JsonData
  DATA_PATH = '../../data/'
  EVENTS_PATH = '/events/'

  def readJson(path)
    f = File.expand_path(path, __FILE__)
    JSON.parse(File.read(f))
  end

  def readJsonData(path)
    readJson(DATA_PATH + path)
  end

  def readJsonEvent(event_id)
    readJsonData(EVENTS_PATH + event_id + '.json')
  end
end