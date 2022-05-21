extends Control

const BUFFER_SIZE = 500

export(String) var default_scene = "main_menu"

var tree
var cur
var prev = []
var inventory = ""
var flags = []
func _ready():
	for rich_text in [$Art, $Dialogue, $Inventory]:
		rich_text.get_child(0).modulate.a = 0
	$Input.grab_focus()
	load_file(default_scene)

func load_file(f_name:String):
	f_name = "res://assets/dialogues/"+f_name+".json"
	var f = File.new()
	f.open(f_name, File.READ)
	var data = f.get_as_text()
	f.close()
	tree = JSON.parse(data).result
	prev = []
	set_dialogue(tree)

func prompt(d):
	var prompt = d["prompt"]
	if(prompt is Array):
		for o in d["prompt"]:
			if(o.has("item")):
				if(o["item"] == "*" or o["item"] == inventory):
					prompt = o["prompt"]
					break
			elif(o.has("flag")):
				if(o["flag"] == "*" or o["flag"] in flags):
					prompt = o["prompt"]
					break
	return prompt

func set_dialogue(d:Dictionary):
	cur = d
	if(d.has("item")):
		$Inventory.text = "Inventory\n"+d["item"]
		inventory = d["item"]
	if(d.has("volume")):
		MusicManager.volume(d["volume"]) # default 0.316228
	match d["type"]:
		"dialogue":
			prev = [d]+prev
			$Dialogue.text += "\n"+prompt(d)+"\n"
			if(d.has("art")):
				display_art(d["art"])
			display_options(d)
		"swap":
			$Dialogue.text = ""
			load_file(d["to"])
		"return":
			for i in range(d["levels"]):
				if(len(prev) <= 1):
					break
				prev.remove(0)
			set_dialogue(prev[0])
		"if":
			prev = [d]+prev
			for o in d["options"]:
				if(o.has("item")):
					if(o["item"] == "*" or o["item"] == inventory):
						set_dialogue(o["dialogue"])
						break
				elif(o.has("flag")):
					if(o["flag"] == "*" or o["flag"] in flags):
						set_dialogue(o["dialogue"])
						break
	if(d.has("flag") and not d["flag"] in flags):
		flags.append(d["flag"])
	if(d.has("music")):
		MusicManager.play(d["music"])

func file_exists(path):
	return Directory.new().file_exists(path)

var prev_art = ""
func display_art(a:String):
	if(a == ""):
		a = "empty"
	if(a == prev_art):
		return
	prev_art = a
	a = "res://assets/art/"+a
	#construct an array of frames
	var frames = []
	var i = 0
	while(file_exists(a+"/"+str(i)+".txt")):
		var f = File.new()
		f.open(a+"/"+str(i)+".txt", File.READ)
		frames.append(f.get_as_text())
		f.close()
		i += 1
	$Art.set_frames(frames)

#input requested
func _on_Input_text_entered(new_text):
	#remove excess text on the top
	var last_char = len($Dialogue.text)-1
	$Dialogue.text = $Dialogue.text.substr(max(last_char-BUFFER_SIZE, 0), (last_char))
	$Input.text = "" # reset the input box
	$Dialogue.text += "\n"+new_text+"\n"
	#display options
	var options = cur["options"]
	for o in options:
		if(o["input"] == "*" or o["input"].to_lower() == new_text.to_lower()):
			set_dialogue(o["dialogue"])
			return
	#invalid input, reshow options
	$Dialogue.text += "Input not recognized.\n\n"+prompt(cur)+"\n"
	display_options(cur)

func display_options(d:Dictionary):
	for o in d["options"]:
		var text = o["display"]
		while(text.find("ITEM") != -1):
			var ind = text.find("ITEM")
			text = text.substr(0, ind) + inventory + text.substr(ind+len("ITEM"))
		$Dialogue.text += text+"\n"
