// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information


function get_player_num(c_id){
	
	with obj_server {
		var player_num = ds_list_find_index(player_list, c_id)
	}
	return player_num
}

function get_player_name(c_id){
	
	var player_num = get_player_num(c_id)
	
	with obj_server {
		var player_name = player_name_list[| player_num]
	}
	return player_name
}