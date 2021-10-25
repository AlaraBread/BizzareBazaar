extends Node

var music = [
	preload("res://assets/music/Car Salesman Final boss.wav"),
	preload("res://assets/music/Car Salesman First meet.wav"),
	preload("res://assets/music/Young Woman.wav"),
	preload("res://assets/music/babushka.wav"),
	preload("res://assets/music/canterburian.wav"),
	preload("res://assets/music/cloaked figure.wav"),
	preload("res://assets/music/sus merchant.wav")]

var cur_music = -1
func play(s):
	if(cur_music == s):
		return
	cur_music = s
	if(s == -1):
		$MusicPlayer.stop()
		return
	$MusicPlayer.stream = music[s]
	$MusicPlayer.play()
