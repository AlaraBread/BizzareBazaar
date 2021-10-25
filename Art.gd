extends RichTextLabel

var frames:Array = []
var cur_frame = 0
func set_frames(frames:Array):
	self.frames = frames
	if(len(frames) > 0):
		text = frames[0]
		cur_frame = 0
		$FrameTimer.start()
	else:
		$FrameTimer.stop()

func _on_FrameTimer_timeout():
	text = frames[cur_frame]
	cur_frame = posmod(cur_frame+1, len(frames))
