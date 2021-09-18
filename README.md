# godot-screen-recorder
A Godot addon that adds a custom node to records a video from a `Viewport`, by using FFmpeg. (alpha)

Based on [Godot Video Rendering Demo](https://github.com/Calinou/godot-video-rendering-demo#godot-video-rendering-demo).

## How to use

Just copy the [ScreenRecorder.gd](src/lib/ScreenRecorder.gd) script to your project and you are good
to go. Be sure to include the copyright notice, just in case. See [LICENSE.md](LICENSE.md) for more
information.

## How it works

It uses the `get_texture()` method from viewport to save a sequence of frames. And then encode the
images in a video using the [FFmpeg library](https://ffmpeg.org/) - Currently by a system call.
You only have to add the `ScreenRecorder` node to the scene-tree and call `start()` and then
`stop()`, the game will freeze for a while and the said node will emit the `process_completed`
signal with a path to the output.

### Problems

- The process of saving and encoding is slow.
- You need to compile and then run the project with the `--fixed-frame` flag to force all frames to
be rendered without skipping.
- The user need to have `ffmpeg` available in their machine, and added as an environment variable to
the system path.
- The game freezes while encoding.

## Future goals

Saving images and then encode them is not optimal, in any way. The better fashion to do it with
Godot is, probably, by using a GdNative extension that captures the frames directly and then encode
to a file using FFmpeg. *─ As a novice student, I do not have the skills needed to dive into it, and*
*so, will saves that for later. Feel free to help, if interested.*

You may want to attach the FFmpeg library directly into your game. The [Godot Video Decoder](https://github.com/kidrigger/godot-videodecoder#godot-video-decoder)
may help with that. ─ *Note that, that project is only meant to add decodes to expand Godot's*
*options. It only loads parts of the ffmpeg library. But, makes it easier to include more sources*
*from there.*

Final goal: High performance real time recording.

## What this can be used for?

In the current state,

you can use it for rendering animations you make with Godot. So you can take advantage of the Godot
easy-to-use programmability to save procedural animations, add fancy shaders, and be creative.

In the future, maybe,

to generate in-game replay videos and time-lapses (like these nice ones from Oxygen Not Included).

### Why not to use OBS?

You can totally use it, but it may cost you some quality to your work. Rendering directly from the
engine may be the best choice for a raw quality product.

You can use the addon to render parts of the tree. It allows you to hide the GUI out of the video,
for example.

Also, you have not the option to "just use OBS" when making custom embed tools, or as a feature in
your game.
