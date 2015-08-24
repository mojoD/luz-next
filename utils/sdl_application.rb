#
# SDL handles graphics system init, timing, and sleeping in a cross-platform way
#
# http://www.libSDL2.org
#
class SDLApplication
	include Drawing

	attr_accessor :width, :height, :fullscreen, :border, :bits_per_pixel, :frames_per_second
	boolean_accessor :finished
	boolean_accessor :system_mouse

	def initialize(name)
		@name, @width, @height, @bits_per_pixel = name, 0, 0, 0		# NOTE: setting bpp to 0 means "current" in SDL
		@fullscreen = true
		@stencil_buffer = true
		@border = true

		# Frame rate should, ideally, match that of LCD, projector, etc.
		# TODO: add an option for syncing to output device refresh rate, as a way to limit refresh rate.
		@frames_per_second = 60
	end

	def create
		init_sdl
		set_video_mode
		init_gl_viewport
	end

	def toggle_fullscreen!
		@fullscreen = !@fullscreen
		set_video_mode
		init_gl_viewport
	end

	#
	# Main Loop
	#
	def run
		start_time_ms = SDL2.get_ticks
		frame_number = 1

		while not finished?
			desired_ms_per_frame = (1000 / @frames_per_second)		# NOTE: desired FPS can change at any time

			frame_start_ms = SDL2.get_ticks
			age_in_seconds = (frame_start_ms - start_time_ms) / 1000.0

			while event = SDL2::Event.poll
				handle_sdl_event(event)
			end

			do_frame(age_in_seconds)

			#SDL2.GL_swap_buffers
			@window.gl_swap

			frame_duration_ms = SDL2.get_ticks - frame_start_ms

			# sleep a bit...
			sleep_time_ms = desired_ms_per_frame - frame_duration_ms
			SDL2.delay(sleep_time_ms) if sleep_time_ms > 3		# for tiny amounts it doesn't make sense

			frame_number += 1
		end
		after_run((SDL2.get_ticks - start_time_ms) / 1000.0)
	end

	#
	# Screenshots
	#
	def get_framebuffer_rgb
		GL.Flush
		GL.ReadPixels(0, 0, @width, @height, GL::RGB, GL::UNSIGNED_BYTE)
	end

	def save_framebuffer_to_file(path)
		image = Magick::Image.new(width, height)
		image.import_pixels(0, 0, width, height, "RGB", get_framebuffer_rgb, Magick::CharPixel)
		image.flip!			# data comes at us upside down
		image.write(path)
	end

private

	def init_sdl
		puts "Using SDL2 bindings version #{SDL2::VERSION}"
		SDL2.init(SDL2::INIT_VIDEO | SDL2::INIT_TIMER)

		if @width == 0 || @height == 0
			display_mode = SDL2::Display.displays.first.desktop_mode
			@width, @height = display_mode.w, display_mode.h
		end

		# Window
		#SDL2::WM.set_caption(@name, '')		UPGRADE

		# Keyboard
		#SDL2::Key.disable_key_repeat		UPGRADE		# We want one Down and one Up message per key press

		# Mouse
		hide_mouse unless system_mouse?
	end

	def hide_mouse
		# NOTE: using a blank cursor works better than SDL2::Mouse.hide with Wacom tablets
		SDL2::Mouse.setCursor(SDL2::Surface.new(SDL2::HWSURFACE,8,8,8,0,0,0,0),1,1,0,1,0,0)
	end

	def set_video_mode
		#SDL2.setGLAttr(SDL2::GL_STENCIL_SIZE, 8) if @stencil_buffer		UPGRADE
		#@screen = SDL2.set_video_mode(@width, @height, @bits_per_pixel, sdl_video_mode_flags)

@window = SDL2::Window.create(@name, 0, 0, @width, @height, sdl_video_mode_flags)
@context = SDL2::GL::Context.create(@window)

		# See what we got
		@width, @height = *@window.size
		#@bits_per_pixel = @window.bpp if @bits_per_pixel == 0		UPGRADE

		puts "Running at #{@width}x#{@height} @ #{@bits_per_pixel}bpp, #{@frames_per_second}fps (max)"
	end

	def sdl_video_mode_flags
		flags = SDL2::Window::OPENGL
		flags |= SDL2::Window::FULLSCREEN_DESKTOP if @fullscreen
		flags |= SDL2::Window::MAXIMIZED if @fullscreen
		flags |= SDL2::Window::RESIZABLE if !@fullscreen
		flags |= SDL2::Window::BORDERLESS unless @border
		flags
	end

	def init_gl_viewport
		GL.Viewport(0, 0, @width, @height)
		clear_screen([0.0, 0.0, 0.0, 0.0])
	end
end
