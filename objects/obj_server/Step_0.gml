/// @description
if (backspace_lag > 0) backspace_lag--
if keyboard_check_pressed(vk_enter) {
	add_line(USER_TYPED, "> "+input)
	array_push(input_list, input)
	input_index = array_length(input_list)
	var input_arr = string_get_words(input)
	var command = input_arr[0]
	var args = ""
	if (array_length(input_arr) == 2) args = input_arr[1]
	var key = variable_struct_get(command_list, input_arr[0])
	if (key == undefined) add_line(ERROR, "Unknown command. Use 'list' for help")
	else {
		if args == "" command_list[$ command].func()
		else command_list[$ command].func(args)
	}
	input = ""
	autocomplete_text = ""
}
else if keyboard_check_pressed(vk_anykey) && (is_letter() || is_number() || is_dot()) {
	if (string_length(input) < command_max_length) input += keyboard_lastchar
	autocomplete_find(input)
	backspace_lag = 30
}
else if keyboard_check(vk_anykey) && (is_letter() || is_number() || is_dot()) {
	if (string_length(input) < command_max_length) && (backspace_lag == 0) {
		input += keyboard_lastchar
		autocomplete_find(input)
		backspace_lag = 2
	}
}
else if keyboard_check_pressed(vk_backspace) {
	input = string_delete(input,string_length(input),1)
	autocomplete_find(input)
	backspace_lag = 30
}
else if keyboard_check(vk_backspace) {
	if (backspace_lag == 0) {
		input = string_delete(input,string_length(input),1)
		autocomplete_find(input)
		backspace_lag = 2
	}
}
else backspace_lag = 0