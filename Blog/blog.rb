require 'date'
class Blog

	def initialize
		@posts = []
	end

	def add_post(title,date,text)
		@posts << { "title" => title, "date" => date, "text" => text}
	end

	def front_page
		order_post = @posts.sort_by{ |item| item['date'].to_i }

		order_post.each do |item|
			puts item["title"]
			puts '****************'
			puts item["text"]
			puts '----------------'
		end
	end
end

#EXECUTION
blog = Blog.new
blog.add_post("titulo 1", DateTime.now.strftime('%s'), "texto 1")
blog.add_post("titulo 2", DateTime.now.strftime('%s'), "texto 2")
blog.add_post("titulo 3", DateTime.now.strftime('%s'), "texto 3")
blog.front_page