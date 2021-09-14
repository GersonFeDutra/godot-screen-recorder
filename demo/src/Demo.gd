extends Node

## Project based in Godot video rendering demo https://github.com/Calinou/godot-video-rendering-demo
## See `LICENSE.md` included in the source distribution for details.

enum State {
	WAIT,
	RECORD,
	STOP,
	PLAY,
}
const RENDER_DIR: String = "render"
const FRAMES_DIR: String = "%s/frames" % RENDER_DIR

var state: int = State.WAIT
var renders: int = 0
var first_frame: int = 0
var current_folder: String
onready var button: Button = $Button

#### 

# Copyright © 2019 Hugo Locurcio and contributors - MIT License
# Modified by GersonFeDutra © 2021.

func _ready() -> void:
	set_process(false)
	get_viewport().msaa = Viewport.MSAA_2X
	
	var directory: = Directory.new()
	var path: String = "user://%s" % RENDER_DIR
	
	if not directory.dir_exists(path) and directory.make_dir(path) != OK:
		push_error("Wouldn't able to create render folder.")
		get_tree().quit(ERR_CANT_CREATE)


func _process(_delta: float) -> void:
	
	print(
			"Rendering frame {frame}...".format({
				frame = Engine.get_frames_drawn(),
			})
	)
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	
	var image := get_viewport().get_texture().get_data()
	
	if image.generate_mipmaps() != OK:
		push_warning("Woldn't able to generate mipmaps")
	
	# The viewport must be flipped to match the rendered window
	image.flip_y()
	
	if image.save_png("%s/%d.png" % [current_folder, Engine.get_frames_drawn()]) != OK:
		push_warning("Woldn't able to save frame %d." % Engine.get_frames_drawn())

####

func _on_Button_pressed() -> void:
	
	match state:
		State.WAIT:
			var directory := Directory.new()
			var path: String = "user://%s" % FRAMES_DIR
			
			state = State.RECORD
			button.text = "Stop"
			current_folder = "%s%d" % [path, renders]
			
			while directory.dir_exists(current_folder):
				renders += 1
				current_folder = "%s%d" % [path, renders]
			
			if directory.make_dir(current_folder) != OK:
				push_error("Wouldn't able to create frames folder.")
				get_tree().quit(ERR_CANT_CREATE)
			
			first_frame = Engine.get_frames_drawn()
			
			if first_frame == 0:
				# If, for some reason, we start recording from start, we skip the first frame that
				# is always empty.
				yield(get_tree() ,"idle_frame")
			
			if not OS.has_feature("standalone"):
				push_warning("FPS may be wrong on export, be sure to export and run the project " +
						"with the `--fixed-fps 60` flag.")
			
			set_process(true)
		State.RECORD:
			var wait_label: Label = $WaitLabel
			set_process(false)
			state = State.STOP
			$Sprite.queue_free()
			wait_label.show()
			yield(get_tree(), "idle_frame")
			
			if OS.is_debug_build():
				var user_dir: String = OS.get_user_data_dir()
				var exit_code: int = OS.execute("ffmpeg", PoolStringArray(["-start_number",
						str(first_frame), "-r", "60", "-f", "image2", "-s", "2560x1440", "-i",
						"{frames_dir}/%d.png".format({
								frames_dir = user_dir + "/" + FRAMES_DIR + str(renders)
							}), "-vcodec", "libx264", "-crf", "15",
						"{output_dir}/video{renders}.mp4".format({
								output_dir = user_dir + "/" + RENDER_DIR,
								renders = renders,
							})]))
				
				if exit_code != OK:
					push_error("Woldn't able to complete the rendering")
			
			wait_label.hide()
			button.text = "Play"
		State.STOP:
			state = State.PLAY
			button.text = "Exit"
		State.PLAY:
			get_tree().quit()
