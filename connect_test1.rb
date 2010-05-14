require 'RightApi'



api = RightAPI.new	
api.log = true
api.login(:username => '', :password => '', :account => '')


servers = api.send("servers") 

puts servers

