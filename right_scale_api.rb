require 'rubygems'
require 'right-scale-api'


def init(args)
	creds = {}
	passwdFile = File.open(args[0], "r")
	passwdFile.each do |line|
		line.strip!
		creds[line.split('=')[0]] = line.split('=')[1]	
	end
	return creds
end

def showActive(myservers)
	myservers["servers"].each do |server|
		#puts server["nickname"]
		if server["state"] == "operational"
			#puts server["href"]
			print "server ID == #{server["href"].split('/')[-1]}\n"
			print "server nickname == #{server["nickname"]}\n"
			puts ""
		end
	end
end

args = ARGV

creds = init(args)


RightScaleAPI::Client.login creds["username"], creds["password"] 
#RightScaleAPI::Account.get id
myservers = RightScaleAPI::Client.get('https://my.rightscale.com/api/acct/25875/servers')


showActive(myservers)
