require 'json'

require_relative 'data'
include JsonData

OUTPUT_PATH = '../../output/'

d = JsonData.readJsonEvent('welcome-drinks-2018')
print(d)