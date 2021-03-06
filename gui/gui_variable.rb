class GuiVariable < GuiListSelect
	def initialize(object, method)		# options is [[:one,'One'],[:two,'Two']]
		super(object, method)
		@item_aspect_ratio = 4.0
	end

	def list
		$engine.project.variables.map { |variable| GuiObjectRenderer.new(variable) }
	end

	def set_value(value)
		super(value.object) if value
	end
end
