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
=begin

	This a pretty rough part of the ruby RS API due to the way that it returns the data.
	The XML format is also a little rough--pick your poison.
	It returns an array (group of server arrays) of hashes (information describing that array instance), 
	which in turn contain arrays (of the information about specific parts of that server array.

=end
	#puts "ip.class is " + ip.class.to_s
	#puts "ip.length is " + ip.length.to_s


	i = 0
	ip.each do |bob|
		addy, name = bob.split('###')
		puts addy
		puts name	
		array_settings = RightScaleAPI::Client.get(addy.to_s+"/instances")
		#puts "array_settings.class " + array_settings.class.to_s

		array_settings.each_key do |key|
			#puts array_settings[key].class
			array_settings[key].each do |server|
				server.each_key do |killmenow|
					# puts killmenow.to_s + " == " + server[killmenow].to_s	
					#if killmenow == "ip_address"
						puts killmenow.to_s + " == " + server[killmenow].to_s
					#end
				end
				puts "------------------------"
			end
			#print key.to_s + " == " + array_settings[key].to_s  + "\n"
			puts ""
			puts " * * * * * * * * * * * "
			puts ""
		end
		i = i + 1
	end


end

def extricateArrayIP(myarrays)
	# pulling out a specific URL based on "nickname"

	array_nicknames = []
	ip_list = []
	myarrays["server_arrays"].each do |server|
		server.each_key do |s|
			if server["nickname"] =~ /production/
				ip_list << server["href"].to_s+"###"+server["nickname"].to_s
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
	ip_list = extricateArrayIP(myarrays)
	extricateArrayInfo(ip_list)

		

	#start_stop(myservers, "tomcat_test2", args[1])
rescue => err
	puts " -- " + err.backtrace.to_s
	puts "failed do to previous errors"
end

