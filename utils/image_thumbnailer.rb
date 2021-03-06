# ImageThumbnailer doesn't thumbnail images (yet?), instead it looks for existing desktop thumbnails
# as per FreeDesktop spec: http://specifications.freedesktop.org/thumbnail-spec/thumbnail-spec-latest.html

require 'digest'

class ImageThumbnailer
	def add(path, &proc)
		full_path = File.join(thumbnail_directory_path, thumbnail_file_name_for_path(path))
		proc.call(full_path) if File.exists?(full_path)
	end

private

	def thumbnail_directory_path
		File.join(Dir.home, '.thumbnails/normal')
	end

	def thumbnail_file_name_for_path(path)
		thumbnail_hash_for_path(path)+'.png'
	end

	def thumbnail_hash_for_path(path)
		absolute_path = 'file://'+File.absolute_path(path)		# "absolute canonical URI"		TODO: more proper way to do this?
		Digest::MD5.hexdigest(absolute_path)
	end
end
