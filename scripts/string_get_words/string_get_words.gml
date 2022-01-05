//Divides all words (spaces) and gives an array size of words
function string_get_words(text){
	var s = string_length(text)
	var arr = []
	var current_string = ""
	for(var i = 0; i < s; i++) {
		var c = string_char_at(text, i+1)
		if (c != " ") current_string+=c
		else {
			arr[array_length(arr)] = current_string
			current_string = ""
		}
		if (i == s-1) arr[array_length(arr)] = current_string
	}
	if array_length(arr) == 0 arr[0] = ""
	return arr;
}