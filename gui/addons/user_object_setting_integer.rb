class UserObjectSettingInteger
	def gui_build_editor
		box = GuiBox.new
		box << create_user_object_setting_name_label
		box << @widget = GuiInteger.new(self, :animation_min, @min, @max).set(:scale_x => 0.15, :offset_x => -0.5 + 0.075, :scale_y => 0.5, :offset_y => 0.0)
		@minus_button = GuiButton.new.set(:scale_x => 0.07, :scale_y => 0.32, :offset_x => -0.5 + 0.15 + 0.035, :offset_y => -0.03, :background_image => $engine.load_image('images/buttons/minus.png'), :background_image_hover => $engine.load_image('images/buttons/minus-hover.png'))
		@minus_button.on_clicked { decrement! }
		@minus_button.on_holding { decrement! if $env[:is_beat] }
		box << @minus_button
		@plus_button = GuiButton.new.set(:scale_x => 0.07, :scale_y => 0.32, :offset_x => -0.5 + 0.15 + 0.035 + 0.07, :offset_y => -0.03, :background_image => $engine.load_image('images/buttons/plus.png'), :background_image_hover => $engine.load_image('images/buttons/plus-hover.png'))
		@plus_button.on_clicked { increment! }
		@plus_button.on_holding { increment! if $env[:is_beat] }
		box << @plus_button
		box
	end

	def increment!
		@widget.set_value(@widget.get_value + 1)
	end

	def decrement!
		@widget.set_value(@widget.get_value - 1)
	end
end
