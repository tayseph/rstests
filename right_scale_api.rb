require 'rubygems'
require 'right-scale-api'


RightScaleAPI::Client.login '', ''
#RightScaleAPI::Account.get id

myservers = RightScaleAPI::Client.get('https://my.rightscale.com/api/acct/25875/servers')


def showActive(myservers)
	myservers["servers"].each { |server|
		#puts server["nickname"]
		if server["state"] == "operational"
			#puts server["href"]
			print "server ID == #{server["href"].split('/')[-1]}\n"
			print "server nickname == #{server["nickname"]}\n"
			puts ""
		end
	}
end

showActive(myservers)
