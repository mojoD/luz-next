class String
	boolean_accessor :shift, :control, :alt		# modifier keys for user input

	def any_modifiers?
		shift || control || alt
	end
	def no_modifiers?
		!shift && !control && !alt
	end

	def shifted
		@shifted || self
	end
	attr_writer :shifted
end
