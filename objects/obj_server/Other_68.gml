var t = ds_map_find_value(async_load, "type");

switch(t) {
    case network_type_connect:
        var sock = ds_map_find_value(async_load, "socket")
		var ip = ds_map_find_value(async_load, "ip")
		if (game_started) {
			buffer_seek(buffer,buffer_seek_start,0)
			buffer_write(buffer,buffer_u8,NET_ALREADY_STARTED)
			buffer_write(buffer,buffer_string,"Game is currently in progress")
			network_send_packet(sock,buffer,buffer_tell(buffer))
		}
		else if ds_list_find_index(banned_ips, ip) != -1 {
			buffer_seek(buffer,buffer_seek_start,0)
			buffer_write(buffer,buffer_u8,NET_BLACKLISTED)
			buffer_write(buffer,buffer_string,"Your IP is banned from this server")
			network_send_packet(sock,buffer,buffer_tell(buffer))	
		}
		else {
			add_line(LOG, "Socket joined (ID: " + string(sock) + ", Index: " + string(num_players) + ")")
	        ds_list_add(player_list, sock)
			ds_list_add(player_ip_list, ip)
			ds_list_add(player_name_list, string(sock))
			ds_list_add(card_number, 0)
			relay_rules(sock)
				buffer_seek(buffer,buffer_seek_start,0)
				buffer_write(buffer,buffer_u8,NET_USER_INTRODUCTION)
				network_send_packet(sock,buffer,buffer_tell(buffer))	
		}
		num_players++
        break;
    case network_type_disconnect:
		var sock = ds_map_find_value(async_load, "socket")
		var i = ds_list_find_index(player_list, sock)
		num_players--;
		if (i != -1) { //make sure the user has made an introduction to the server
			add_line(LOG, "Socket disconnect (ID: " + string(sock) + ", Index: " + string(i) + ")")
			var p_name = player_name_list[| i]
			ds_list_delete(player_list, i)
			ds_list_delete(player_name_list, i)
			ds_list_delete(player_ip_list, i)
			ds_list_delete(card_number, i)
			update_players()
			if (game_started) {
				if (num_players <= 1) stop_game()
				else {
					must_draw_cards = 0
					if (player_turn >= num_players) player_turn = 0
					for (var j = 0; j < num_players; j++) {
						var sock = player_list[| j]
						buffer_seek(buffer,buffer_seek_start,0)
						buffer_write(buffer,buffer_u8,NET_DISCONNECT_CHANGE_TURN)
						buffer_write(buffer,buffer_u8,player_turn)
						network_send_packet(sock,buffer,buffer_tell(buffer))
					}
				}
			}
			for (var j = 0; j < num_players; j++) {
				var sock = player_list[| j]
				buffer_seek(buffer,buffer_seek_start,0)
				buffer_write(buffer,buffer_u8,NET_RELAY_MESSAGE)
				buffer_write(buffer,buffer_bool,true)
				buffer_write(buffer,buffer_string,p_name + " disconnected.")
				network_send_packet(sock,buffer,buffer_tell(buffer))
			}
		}	
		break;
    case network_type_data:
		var c_buffer = ds_map_find_value(async_load, "buffer")
		var c_buffer_size = ds_map_find_value(async_load, "size")
		var c_id = ds_map_find_value(async_load, "id")
		received_packet(c_buffer, c_id, c_buffer_size)
        break;
}