///Reads buffer but does not crash game if it is out of bounds
function buffer_read_safe(buffer, buffer_size, type) {
	var def_return = -1
	switch(type) {
		case buffer_string:
		case buffer_text:
			def_return = ""
			break;
	}
	if (buffer_tell(buffer) < buffer_size) def_return = buffer_read(buffer, type)
	return def_return
}