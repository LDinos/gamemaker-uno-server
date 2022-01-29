function buffer_process(entry_value, types_array, values_array) {
	buffer_seek(buffer,buffer_seek_start,0) //the buffer here is the server created one
	var len = array_length(types_array) //the user should use both type and value arrays with same size
	buffer_write(buffer, buffer_u8, entry_value)
	for(var i = 0; i < len; i++) {
		var b_type = types_array[i]
		var v_type = values_array[i]
		buffer_write(buffer, b_type, v_type)
	}
}