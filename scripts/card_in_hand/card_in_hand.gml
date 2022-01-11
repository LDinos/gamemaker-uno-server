// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information


function card_in_hand(player_num, card) {
	
	with obj_server {
		
		if card % 15 == WILDCARDCOLOR and card > 0 and card < 60 {
			card = WILDCARD
		}
		else if card % 15 == PLUSFOURCOLOR and card > 0 and card < 60 {
			card = PLUSFOUR
		}
		
		if is_undefined(player_hand_list[| player_num]) {
			player_hand_list[| player_num] = []
		}
		
		var array = player_hand_list[| player_num]
		
		//yikes this is unoptimised, it wont get called that much tho so its prob fine
		//search for the specific card in the players hand, if we find it, return true. otherwise return false
		for (var i = 0; i < array_length(array); i++) {
			if array[i] = card {
				return true
			}
		}
		
		return false
	}
}

function add_card_to_hand_list(player_num, card){
	
	with obj_server {
		if is_undefined(player_hand_list[| player_num]) {
			player_hand_list[| player_num] = []
		}
		
		array_push(player_hand_list[| player_num], card)
		
	}
}


function remove_card_from_hand_list(player_num, card){
	

	
	with obj_server {
		
		if card % 15 == WILDCARDCOLOR and card > 0 and card < 60 {
			card = WILDCARD
		}
		else if card % 15 == PLUSFOURCOLOR and card > 0 and card < 60 {
			card = PLUSFOUR
		}
		
		if is_undefined(player_hand_list[| player_num]) {
			player_hand_list[| player_num] = []
		}
		
		var array = player_hand_list[| player_num]
		
		//yikes this is unoptimised, it wont get called that much tho so its prob fine
		//search for the specific card in the players hand, once we find it, delete it and break the loop
		for (var i = 0; i < array_length(array); i++) {
			if array[i] = card {
				array_delete(player_hand_list[| player_num], i, 1)
				break;
			}
		}
		
		
	}
}