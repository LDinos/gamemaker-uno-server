// List of commands
function list_function() {
	var array = variable_struct_get_names(command_list);
	for(var i = 0; i < array_length(array); i++) {
		add_line(USER_ANSWER, "- " + array[i])
	}
}

function unban_function(ip = "") {
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


function banip_function(ip = "") {
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

function ban_function(name = "") {
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

function banlist_function() {
	if ds_list_empty(banned_ips) {return add_line(USER_ANSWER, "No banned ips were found.")}
	for(var i = 0; i < ds_list_size(banned_ips); i++) {
		add_line(USER_ANSWER, banned_ips[| i])
	}
}

function players_function() {
	add_line(USER_ANSWER, string(num_players) + " players are connected.")
	for(var i = 0; i < num_players; i++) {
		var start = ""
		if (i == 0) start = "- "
		add_line(USER_ANSWER, start + player_name_list[| i] + " : " + string(player_list[| i]))
	}
}

function deck_function() {
	add_line(USER_ANSWER, "Deck currently has " + string(ds_list_size(deck)) + " cards.")
}

function whois_function(name = "") {
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

function clear_function() {
	log_lines = []
}

function version_function() {
	add_line(USER_ANSWER, global.version)
}

function initialize_commands(){
	command_list = {
		ban : ban_function,
		banip : banip_function,
		unban : unban_function,
		banlist : banlist_function,
		list : list_function,
		help : list_function,
		restart : room_restart,
		deck : deck_function,
		clear : clear_function,
		players : players_function,
		whois : whois_function,
		ver : version_function
	}
}