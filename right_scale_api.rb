require 'rubygems'
require 'right-scale-api'


def init(args)
	begin
		creds = {}
		passwdFile = File.open(args[0], "r")
		passwdFile.each do |line|
			line.strip!
			creds[line.split('=')[0]] = line.split('=')[1]	
		end
		return creds
	rescue => err
		puts "argument missing, probably the name of the credential file"
		puts " -- " +err
	end
end

def start_stop(myservers, nickname, arg)
	myservers["servers"].each do |server|
		#puts server["nickname"]
		if server["nickname"] == nickname
			#puts server["href"]
			print "server ID == #{server["href"].split('/')[-1]}\n"
			sid = server["href"].split('/')[-1]
			print "https://my.rightscale.com/api/acct/25875/servers/#{sid}/#{arg}\n"
			RightScaleAPI::Client.post("https://my.rightscale.com/api/acct/25875/servers/#{sid}/#{arg}")
		end
	end
end

def getIP(server)
	# should probably depricate this. 
	# gets the "settings" which is a list of things including the IPs

	#puts myservers["servers"].class
	firstserver = server.pop
	#puts first.class
	firstsettings = RightScaleAPI::Client.get(firstserver["href"]+"/settings")
	#puts firstsettings.class	
	#puts firstsettings["settings"].class	
	#firstsettings["settings"].each_key do |key|
#		puts key.to_s + " == " + firstsettings["settings"][key].to_s
		
#	end
	return firstsettings
end

def showActiveServers(myservers)
	# outputting information from a server "get" based on "nickname"	

	myservers["servers"].each do |server|
		#puts server["nickname"]
		if server["state"] == "operational"
			puts server["nickname"]
			if server["nickname"] =~ /production-tomcat/
				print "server ID == #{server["href"].split('/')[-1]}\n"
				print "server nickname == #{server["nickname"]}\n"
				server_settings = getIP(server)
				puts ""
			end
		end
	end
end

def extricateArrayInfo(ip)

	puts ip.class

	array_settings = RightScaleAPI::Client.get(ip[0]+"/instances")
	puts array_settings

	array_settings.each_key do |key|
		puts key.to_s + " == " + array_settings[key].to_s
	end

=begin
	myarrays["server_arrays"].each do |server|
		server.each_key do |s|
			if server["nickname"] =~ /production/
				ip_list << server["href"]
			end
		end
	end 
	return ip_list.uniq!	
=end
end

def extricateArrayIP(myarrays)
	# pulling out a specific URL based on "nickname"

	ip_list = []
	myarrays["server_arrays"].each do |server|
		server.each_key do |s|
			if server["nickname"] =~ /production/
				ip_list << server["href"]
			end
		end
	end 
	return ip_list.uniq!	
end

args = ARGV

#puts args[0]
#puts args[1]

begin
	creds = init(args)
	RightScaleAPI::Client.login creds["username"], creds["password"] 
	#myservers = RightScaleAPI::Client.get('https://my.rightscale.com/api/acct/25875/servers')
	myarrays = RightScaleAPI::Client.get('https://my.rightscale.com/api/acct/25875/server_arrays')
	#mydeployments = RightScaleAPI::Client.get('https://my.rightscale.com/api/acct/25875/deployments')

	#showActiveServers(myservers)
	list = extricateArrayIP(myarrays)
	extricateArrayInfo(list)

		

	#start_stop(myservers, "tomcat_test2", args[1])
rescue => err
	puts " -- " + err.backtrace.to_s
	puts "failed do to previous errors"
end

