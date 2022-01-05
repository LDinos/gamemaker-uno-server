// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function is_letter() {
	return (keyboard_lastkey >= 65 && keyboard_lastkey <= 90) || keyboard_lastkey == vk_space
}

function is_number() {
	return keyboard_lastkey >= 48 && keyboard_lastkey <= 57
}

function is_dot() {
	return keyboard_lastkey == 190
}