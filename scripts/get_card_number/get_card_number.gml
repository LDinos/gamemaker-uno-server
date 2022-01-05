#macro WILDCARD 60 //use 'card' with this
#macro PLUSFOUR 61 // use 'card' with this
#macro INVERT 10 //use 'get_card_number' from then on
#macro PLUSTWO 11
#macro SKIP 12
#macro WILDCARDCOLOR 13
#macro PLUSFOURCOLOR 14

function get_card_number(card){
	return (card mod 15)
}