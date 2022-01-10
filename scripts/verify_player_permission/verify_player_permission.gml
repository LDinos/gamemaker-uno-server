// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

enum permission_type {
	IS_HOST,
	IS_PLAYERS_TURN,
	IS_PLAYING
}
function verify_player_permission(c_id, type){
	
	switch type {
		
		//if checking for host, see if the ip is the first player
		case permission_type.IS_HOST:
			with obj_server {
				var player_num = get_player_num(c_id)
				if player_num == 0 {
					return true
				}
				return false
			}
			break; //redundant xd
		
		//check to see if the turn is equal to the player number
		case permission_type.IS_PLAYERS_TURN:
			with obj_server {
				var player_num = get_player_num(c_id)
				if player_num == player_turn {
					return true
				}
				return false	
			}
			break;
			
		case permission_type.IS_PLAYING:
			with obj_server {
				var player_num = get_player_num(c_id)
				if player_num != -1 {
					return true
				}
				return false
			}
			break;
			
		default:
			return false
		
	}
}