/// @description

#region MACROS
#macro MAX_LINES 17
#macro num_cards 62
#macro ERROR 0
#macro SUCCESS 1
#macro LOG 2
#macro ALERT 3
#macro USER_TYPED 4
#macro USER_ANSWER 5
#macro TEXT 0
#macro COLOR 1
#macro NET_GET_NAME 0
#macro NET_UPDATE_PLAYERS 1
#macro NET_START_GAME 2
#macro NET_INITIAL_CARDS 3
#macro NET_GET_PLAYED_CARDS 4
#macro NET_PLAY_CARDS 5
#macro NET_GET_DRAW_CARDS 6
#macro NET_SEND_DRAW_CARDS 7
#macro NET_SERVER_EXIT 8
#macro NET_WRONG_VER 9
#macro NET_BLACKLISTED 10
#macro NET_ALREADY_STARTED 11
#macro NET_DISCONNECT_CHANGE_TURN 12
#macro NET_GET_RULE_UPDATE 13
#macro NET_RELAY_RULE_UPDATE 14
#macro NET_USER_INTRODUCTION 15
#macro NET_GET_MESSAGE 16
#macro NET_RELAY_MESSAGE 17
#macro NET_STOP_GAME 18
#endregion

ini_open("settings.ini")
	port = ini_read_real("settings", "port", 6969)
	max_clients = ini_read_real("settings", "max_clients", 10)
ini_close()
global.version = "0.10.1" //current server version
version_allowances = ["0.10", global.version] //if client has any of these versions, they can join
window_set_size(460,320)

#region INITIAL FUNCTIONS
function autocomplete_find(text) {
	var list_commands = variable_struct_get_names(command_list)
	var bestchars = 0
	var bestcmd = ""
	for(var i = 0; i < array_length(list_commands); i++) {
		var curchar = 0;
		for(var j = 0; j < string_length(text); j++) {
			if string_char_at(text, j+1) == string_char_at(list_commands[i], j+1) {
				curchar++
			} else {curchar = 0 break;}
		}
		if (curchar > bestchars) {bestcmd = list_commands[i]; bestchars = curchar}
	}
	autocomplete_text = bestcmd
}

function add_line(type, text) {
	var color = c_white
	
	switch(type) {
		case ERROR: color = c_red; break;
		case SUCCESS: color = c_green; break;
		case LOG: color = c_white; break;
		case ALERT: color = c_yellow; break;
		case USER_TYPED: color = c_fuchsia; break;
		case USER_ANSWER: color = c_aqua; break;
		default: color = type;
	}

	var size = array_length(log_lines)
	log_lines[size][TEXT] = text
	log_lines[size][COLOR] = color
	if (size > MAX_LINES) array_delete(log_lines,0,1)
}

function create_deck() {
	// A deck consists of colored cards (x2) + Wildcard (x4) + Plus four (x4)
	ds_list_clear(deck)
	repeat(2) {
		for(var i = 0; i < num_cards; i++) {
			if (get_card_number(i) < WILDCARDCOLOR) ds_list_add(deck,i) //DONT ADD COLORED VERSIONS OF WILDCARD/PLUSFOUR 
		}
	}
	repeat(2) {ds_list_add(deck,WILDCARD); ds_list_add(deck,PLUSFOUR)} //add 2 more (total: 4) of wildcards 
	ds_list_shuffle(deck)
	add_line(LOG, "Deck created. Num cards: " + string(ds_list_size(deck)))
}
	
#endregion

#region INITIAL VARIABLES

//Rules
RULE_draw_until_play = false;
RULE_allow_stacks = true;
RULE_4stack_on_2 = true;

//Log related
anticheat = true
autocomplete_text = ""
log_lines = []
input_list = [] //array that keeps all strings written by the server user
input_index = 0 //index for when the user presses up/down to find latest command that was written
command_max_length = 30
backspace_lag = 0
blink = "|"
alarm[0] = 10
input = ""
initialize_commands()

randomize()
deck = ds_list_create()
banned_ips = ds_list_create()
game_started = false
player_turn = -1
player_turn_clockwise = true
player_list = ds_list_create()
player_name_list = ds_list_create()
player_ip_list = ds_list_create()
card_number = ds_list_create()
player_hand_list = ds_list_create()
ds_list_clear(player_hand_list) //internally some values can get defined as 0 instead of undefined and its important that doesnt happen so calling this fixes it
num_players = 0
must_draw_cards = 0
pile_last_card = -1 //tracks the current card on top of the pile

buffer = buffer_create(1,buffer_grow,1)
network_set_config(network_config_connect_timeout, 6000);

#endregion

server = network_create_server(network_socket_tcp, port, max_clients)
if (server < 0) {
	add_line(ERROR, "Unable to create server. Port may be already in use?")
} else {
	add_line(SUCCESS, "Server is open. Port: " + string(port))
	create_deck()
}

#region LATTER FUNCTIONS

function received_packet(c_buffer, c_id, c_buffer_size) {
	var type = buffer_read(c_buffer, buffer_u8)
	switch(type) {
		case NET_GET_NAME:
			var name = buffer_read_safe(c_buffer, c_buffer_size, buffer_string)
			var ver = buffer_read_safe(c_buffer, c_buffer_size,buffer_string)
			if !(game_started) {
				var pos = ds_list_find_index(player_name_list, string(c_id))
				player_name_list[| pos] = name
				if version_is_same(ver) {
					update_players()
					buffer_process(NET_RELAY_MESSAGE, [buffer_bool, buffer_string], [true, name + " connected."])
					network_send_packet_all(c_id)
				} else {
					add_line(ALERT, string(c_id) + " has wrong version ("+ver + " | " +global.version+").")
					buffer_process(NET_WRONG_VER, [buffer_string], ["Wrong version\nYours : " + ver + "\nServer : " + global.version])
					network_send_packet(c_id,buffer,buffer_tell(buffer))
				}
			}
			break;
		case NET_START_GAME:
			//check to make sure the player is the host before beginning the game
			if verify_player_permission(c_id, permission_type.IS_HOST) {		
				if !(game_started) {
					player_turn = -1
					player_turn_clockwise = true
					must_draw_cards = 0
					game_started = true
					add_line(ALERT, "Game started.")
					initial_give_cards()
					
				} else {
					var instigating_player = get_player_name(c_id)
					add_line(ALERT, string(instigating_player) + " tried to start the game, but the game has already begun.")
				}

			} else {
				var instigating_player = get_player_name(c_id)
				add_line(ALERT, string(instigating_player) + " tried to start the game, but is not host.")
			}

			break;
		case NET_STOP_GAME:
			if verify_player_permission(c_id, permission_type.IS_HOST) {
				buffer_process(NET_STOP_GAME,[],[])
				network_send_packet_all()
			}
			stop_game()
			break;
		case NET_GET_PLAYED_CARDS:
			//check to make sure that it is the turn of the player playing the card
			if verify_player_permission(c_id, permission_type.IS_PLAYERS_TURN) {
				if (game_started) {	
					var card = buffer_read_safe(c_buffer, c_buffer_size,buffer_u8)
					var index = ds_list_find_index(player_list, c_id)	
					if card_in_hand(index, card) {
						if can_play_card(card) { //actual card playing code in this if statement
							card_number[| index]--
							remove_card_from_hand_list(index, card)
							var gameover = false //assume no game over
							//look through all the players hands, if one of them is empty, gameover is true
							for (i = 0; i < ds_list_size(card_number); i++) {
								if card_number[| i] <= 0 {
									gameover = true
									break;
								}
							}
							play_card(card, gameover)
							
						} else {
							var instigating_player = get_player_name(c_id)
							add_line(ALERT, string(instigating_player) + " cannot play card " + string(card))
						}
						
					} else {
						var instigating_player = get_player_name(c_id)
						add_line(ALERT, string(instigating_player) + " tried to play a card not in their hand.")
					}
				
				}
				
			} else {
				var instigating_player = get_player_name(c_id)
				add_line(ALERT, string(instigating_player) + " can't play - not their turn.")
			}
			
			break;		
		case NET_GET_DRAW_CARDS:
			//check to make sure that it is the turn of the player drawing the card
			if verify_player_permission(c_id, permission_type.IS_PLAYERS_TURN) {
				if (game_started) {
					var iend = must_draw_cards
					if (iend == 0) iend = 1
					for (var j = 0; j < num_players; j++) {
						var sock = player_list[| j]
						buffer_seek(buffer,buffer_seek_start,0)
						buffer_write(buffer,buffer_u8,NET_SEND_DRAW_CARDS)
						if (j == player_turn) {
							for(var i = 0; i < iend; i++) {
								card_number[| j]++
								var card = deck[| 0]
								
								add_card_to_hand_list(j, card)
								
								buffer_write(buffer,buffer_u8,card)
								deck_deplete_card()
							}
						}
						network_send_packet(sock,buffer,buffer_tell(buffer))
					}
					must_draw_cards = 0
					if (!RULE_draw_until_play || iend > 1) next_turn()
				}
			} else {
				var instigating_player = get_player_name(c_id)
				add_line(ALERT, string(instigating_player) + " can't draw - not their turn.")	
			}
			
			break;
		case NET_GET_RULE_UPDATE:
			//check if player is host before actually changing the rules
			if verify_player_permission(c_id, permission_type.IS_HOST) {
				if !(game_started) {
					RULE_draw_until_play = buffer_read(c_buffer,buffer_bool)
					RULE_allow_stacks = buffer_read(c_buffer,buffer_bool)
					RULE_4stack_on_2 = buffer_read(c_buffer,buffer_bool)
					relay_rules()
				} else {
					var instigating_player = get_player_name(c_id)
					add_line(ALERT, string(instigating_player) + " tried to modify rules, but game has started.")	
				}
				
			} else {
				var instigating_player = get_player_name(c_id)
				add_line(ALERT, string(instigating_player) + " tried to modify rules, but is not host.")	
			}
			break;	
		case NET_GET_MESSAGE:
			var text = buffer_read(c_buffer,buffer_string)
			if string_length(text) <= 99 { //max message length
					buffer_process(NET_RELAY_MESSAGE, [buffer_bool, buffer_string], [false, text])
					network_send_packet_all()
			} else {
				var instigating_player = get_player_name(c_id)
				add_line(ALERT, string(instigating_player) + " sent a chat message that was too long.")	
			}	
			break;
		default: add_line(ALERT, type)
	}
}

function update_players() {
	for (var j = 0; j < num_players; j++) {
		var sock = player_list[| j]
		buffer_seek(buffer,buffer_seek_start,0)
		buffer_write(buffer,buffer_u8,NET_UPDATE_PLAYERS)
		buffer_write(buffer,buffer_u8,num_players)
		buffer_write(buffer,buffer_u8,j)
		for(var i = 0; i < num_players; i++) {
			buffer_write(buffer,buffer_string,player_name_list[| i])
			buffer_write(buffer,buffer_u8,card_number[| i])
		}
		network_send_packet(sock,buffer,buffer_tell(buffer))
	}
}

function play_card(card, gameover = false) {
	pile_last_card = card
	buffer_process(NET_PLAY_CARDS, [buffer_u8, buffer_bool], [card, gameover])
	network_send_packet_all()
	if (!gameover) {
		var how_much = 1
		if get_card_number(card) == SKIP how_much = 2
		else if get_card_number(card) == PLUSTWO must_draw_cards+=2
		else if get_card_number(card) == PLUSFOURCOLOR must_draw_cards+=4
		else if (get_card_number(card) == INVERT) {
			player_turn_clockwise = !player_turn_clockwise
			if (num_players == 2) how_much = 2
		}
		repeat(how_much) next_turn()
	} else stop_game()
}

function initial_give_cards() {
	player_turn = irandom(num_players-1)
	var pile_first = deck[| 0]
	deck_deplete_card()
	if (pile_first == PLUSFOUR) pile_first = PLUSFOURCOLOR + 15*(irandom(3))
	else if (pile_first == WILDCARD) pile_first = WILDCARDCOLOR + 15*(irandom(3))
	
	pile_last_card = pile_first
	
	for (var j = 0; j < num_players; j++) {
		card_number[| j] = 7
		var sock = player_list[| j]
		buffer_seek(buffer,buffer_seek_start,0)
		buffer_write(buffer,buffer_u8,NET_INITIAL_CARDS)
		buffer_write(buffer,buffer_u8,player_turn)
		for(var i = 0; i < 7; i++) //7 = initial cards
		{
			var card = deck[| i]
			
			add_card_to_hand_list(j, card)
			
			buffer_write(buffer,buffer_u8,card)
			deck_deplete_card()
		}
		buffer_write(buffer,buffer_u8,pile_first)		
		network_send_packet(sock,buffer,buffer_tell(buffer))
	}
}

function next_turn() {
	if (player_turn_clockwise) player_turn++
	else player_turn--
	if (player_turn == num_players) player_turn = 0
	else if (player_turn < 0) player_turn = num_players-1
}

function deck_deplete_card(num = 1) {
	repeat(num) {
		ds_list_delete(deck, 0)
		if (ds_list_size(deck) == 0) create_deck()
	}
}

function relay_rules() {
		buffer_process(NET_RELAY_RULE_UPDATE, 
		[buffer_bool, buffer_bool, buffer_bool], 
		[RULE_draw_until_play, RULE_allow_stacks, RULE_4stack_on_2])
		network_send_packet_all()
}

function version_is_same(client_ver) {
	for(var i = 0; i < array_length(version_allowances); i++) {
		if (client_ver == version_allowances[i]) {return true}
	}
	return false
}

function stop_game() {
	for(var i = 0; i < ds_list_size(card_number); i++) card_number[| i] = 0
	game_started = false
	player_turn = -1
	player_turn_clockwise = true
	must_draw_cards = 0
	create_deck()
	add_line(ALERT, "Game end." )
}

#endregion