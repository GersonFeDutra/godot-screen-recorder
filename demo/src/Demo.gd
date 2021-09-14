extends Node

enum State {
	WAIT,
	RECORD,
	STOP,
	PLAY,
}

var state: int = State.WAIT
onready var button: Button = $Button
onready var screen_recorder: ScreenRecorder = $ScreenRecorder
onready var wait_label: Label = $WaitLabel
onready var video_player: VideoPlayer = $CanvasLayer/VideoPlayer


func _on_Button_pressed() -> void:
	
	match state:
		State.WAIT:
			state = State.RECORD
			button.text = "Stop"
			screen_recorder.start()
		State.RECORD:
			state = State.STOP
			$Sprite.queue_free()
			wait_label.show()
			screen_recorder.stop()
		State.STOP:
			state = State.PLAY
			button.text = "Exit"
			video_player.play()
		State.PLAY:
			get_tree().quit()


func _on_ScreenRecorder_process_completed(output_path: String) -> void:
	var stream := VideoStreamTheora.new()
	
	wait_label.hide()
	button.text = "Play"
	stream.set_file(output_path)
	video_player.stream = stream
