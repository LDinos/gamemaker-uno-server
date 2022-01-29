//@param The user who shouldn't get the packet
function network_send_packet_all(user_exception = noone) {
	for (var j = 0; j < num_players; j++) {
		var sock = player_list[| j]
		if (user_exception != sock) {
			network_send_packet(sock,buffer,buffer_tell(buffer))
		}
	}
}