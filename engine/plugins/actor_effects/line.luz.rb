class ActorEffectLine < ActorEffect
	title				"Line"
	description "Draws actor many times in a line."

	category :child_producer

	setting 'number', :integer, :range => 1..100, :default => 1..2, :summary => true
	setting 'angle', :float, :default => 0.0..1.0, :digits => 3
	setting 'distance', :float, :range => -100.0..100.0, :default => 1.0..2.0, :digits => 3

	def render
		with_roll(angle) {
			for i in 0...number
				with_slide(distance * i) {
					with_roll(-angle) {
						yield :child_index => i, :total_children => number
					}
				}
			end
		}
	end
end
