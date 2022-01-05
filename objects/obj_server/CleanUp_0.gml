/// @description
for (var j = 0; j < num_players; j++) {
	var sock = player_list[| j]
	buffer_seek(buffer,buffer_seek_start,0)
	buffer_write(buffer,buffer_u8,NET_SERVER_EXIT)
	buffer_write(buffer,buffer_string,"Server Closed")
	network_send_packet(sock,buffer,buffer_tell(buffer))
}
buffer_delete(buffer)
ds_list_destroy(player_list)
ds_list_destroy(player_name_list)
ds_list_destroy(deck)
ds_list_destroy(banned_ips)
ds_list_destroy(player_ip_list)
ds_list_destroy(card_number)
network_destroy(server)