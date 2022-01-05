/// @description
var log_size = array_length(log_lines)

for(var i = 0; i < log_size; i++) {
	var text = log_lines[i][TEXT]
	var c = log_lines[i][COLOR]	
	draw_text_color(0, room_height - 64 - (log_size-1-i)*16, text, c, c, c, c, 1)
}
var c2 = c_gray
draw_text_color(0, room_height - 24, autocomplete_text, c2, c2, c2, c2, 0.5)
draw_text(0, room_height - 24, input+blink)