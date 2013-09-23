require_relative ('../src/json')
str = File.open(File.dirname(__FILE__)+"/example.json").read
puts JSON.parse(str)
