# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.

include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::Tagging
include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::LinkTo

module PostHelper
	def get_pretty_date(post)
		attribute_to_time(post[:created_at]).strftime('%B %-d, %Y')
	end
	def get_digital_date(post)
		attribute_to_time(post[:created_at]).strftime('%m.%d.%Y')
	end
	def pretty_time(time)
		time = Time.parse(time) if not time.is_a?(Time) and not time.nil?
		time.strftime("%b %d, %Y") unless time.nil?
	end
end

include PostHelper