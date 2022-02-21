// List of commands
function list_function() { with(obj_server) {
	var array = variable_struct_get_names(command_list);
	for(var i = 0; i < array_length(array); i++) {
		add_line(USER_ANSWER, "- " + array[i])
	}
	}
}

function help_function(arg = "") { with(obj_server) {
	if (arg == "") list_function()
	else {
		var strct = variable_struct_get(command_list, arg)
		if (strct != undefined) {
			add_line(USER_ANSWER, strct.help)
		}
		else add_line(ERROR, "No command found called '" + arg + "'")
	}
	}
}

function unban_function(ip = "") { with(obj_server) {
	if ip == ""  add_line(ERROR, "Missing ip argument.")
	else {
		var pos = ds_list_find_index(banned_ips, ip)
		if pos != -1 {
			add_line(SUCCESS, ip + " is now unbanned.")
			ds_list_delete(banned_ips, pos)
		}
		else add_line(ERROR, "IP not found in blacklist.")
	}
	}
}


function banip_function(ip = "") { with(obj_server) {
	if ip == ""  add_line(ERROR, "Missing ip argument.")
	else {
		var pos = ds_list_find_index(banned_ips, ip)
		if pos == -1 {
			add_line(SUCCESS, ip + " is now banned.")
			ds_list_add(banned_ips, ip)
			var is_online = ds_list_find_index(player_ip_list, ip)
			if (is_online != -1) {
				buffer_seek(buffer,buffer_seek_start,0)
				buffer_write(buffer,buffer_u8,NET_BLACKLISTED)
				buffer_write(buffer,buffer_string,"Your IP is banned from this server")
				network_send_packet(player_list[| is_online],buffer,buffer_tell(buffer))	
			}
		}
		else add_line(USER_ANSWER, ip + " is already banned!")
	}
	}
}

function ban_function(name = "") { with(obj_server) {
	if name == "" add_line(ERROR, "Missing name argument.")
	else {
		var is_online = ds_list_find_index(player_name_list, name)
		if (is_online != -1) {
				var ip = ds_list_find_value(player_ip_list, is_online)
				ds_list_add(banned_ips, ip)
				buffer_seek(buffer,buffer_seek_start,0)
				buffer_write(buffer,buffer_u8,NET_BLACKLISTED)
				buffer_write(buffer,buffer_string,"Your IP is banned from this server")
				network_send_packet(player_list[| is_online],buffer,buffer_tell(buffer))	
			}
		else add_line(ERROR, "No user found with that name.")
	}
	}
}

function banlist_function() { with(obj_server) {
	if ds_list_empty(banned_ips) {return add_line(USER_ANSWER, "No banned ips were found.")}
	for(var i = 0; i < ds_list_size(banned_ips); i++) {
		add_line(USER_ANSWER, banned_ips[| i])
	}
	}
}

function players_function() { with(obj_server) {
	add_line(USER_ANSWER, string(num_players) + " players are connected.")
	for(var i = 0; i < num_players; i++) {
		var start = ""
		if (i == 0) start = "- "
		add_line(USER_ANSWER, start + player_name_list[| i] + " : " + string(player_list[| i]))
	}
	}
}

function deck_function() { with(obj_server) {
	add_line(USER_ANSWER, "Deck currently has " + string(ds_list_size(deck)) + " cards.")
	}
}

function whois_function(name = "") { with(obj_server) {
	if (name == "") add_line(ERROR, "Missing name argument.")
	else {
		var pos = ds_list_find_index(player_name_list, name)
		if (pos == -1) add_line(ERROR, "Name not found in player list.")
		else {
			add_line(USER_ANSWER, "Name: " + player_name_list[| pos])
			add_line(USER_ANSWER, "IP: " + player_ip_list[| pos])
			add_line(USER_ANSWER, "Index: " + string(pos))
		}
	}
	}
}

function clear_function() { with(obj_server) {
	log_lines = []
	}
}

function anticheat_function(arg = "") { with(obj_server) {
	if (arg == "") {
		var state = anticheat ? "ON" : "OFF"
		add_line(USER_ANSWER, "Anticheat is " + state)
	}
	else if arg == "on" {
		anticheat = true
		var state = anticheat ? "ON" : "OFF"
		add_line(USER_ANSWER, "Anticheat is now " + state)
	}
	else if arg == "off" {
		anticheat = false
		var state = anticheat ? "ON" : "OFF"
		add_line(USER_ANSWER, "Anticheat is now " + state)
	}
	else add_line(ERROR, "Argument must be 'on' or 'off'.")
	}
}

function version_function() { with(obj_server) {
	add_line(USER_ANSWER, global.version)
}
}

function initialize_commands(){
	command_list = {
		anticheat : {func : anticheat_function, help : "anticheat [off/on] | Toggle anticheat"},
		ban : {func : ban_function, help : "ban [player_name] | Ban connected player"},
		banip : {func : banip_function, help : "banip [ip] | Ban an IP"},
		unban : {func : unban_function, help : "unban [ip] | Unban an IP"},
		banlist : {func : banlist_function, help : "banlist | Show list of banned IPs"},
		list : {func : list_function, help : "list | Show list of commands"},
		help : {func : help_function, help : "help [command] | Read usage of command"},
		restart : {func : room_restart, help : "restart | Restart server"},
		deck : {func : deck_function, help : "deck | Show current deck cards number"},
		clear : {func : clear_function, help : "clear | Clear the log"},
		players : {func : players_function, help : "players | Show connected players"},
		whois : {func : whois_function, help : "whois [name] | Read info for player"},
		ver : {func : version_function, help : "ver | Show server version"}
	}
}