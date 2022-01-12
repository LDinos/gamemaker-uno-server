// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information


//this is more or less a copy of the same function in the client yyp, minus changes to make it work in the server

function can_play_card(card){
	var can_play = false;
	var mycard_color = get_card_color(card)
	var mycard_number = get_card_number(card)
	var pile_color = get_card_color(pile_last_card)
	var pile_number = get_card_number(pile_last_card)
	if (mycard_color != BLACK) and ((mycard_color == pile_color) || (mycard_number == pile_number) || (card % 15 == WILDCARDCOLOR) || (card % 15 == PLUSFOURCOLOR) || (pile_last_card == -1)) {
		if (must_draw_cards != 0) { //if we have to draw cards because of plus two or plus 4
			if (RULE_allow_stacks) {
				if (mycard_number == pile_number) || (card == PLUSFOUR && RULE_4stack_on_2) { //if +4 or plus two on plus two
					can_play = true
				}
			}
		}
		else can_play = true 
	}
	return can_play
}