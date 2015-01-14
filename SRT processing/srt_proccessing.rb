require 'pry'
require 'date'
class SrtProccess
	def initialize(file)
		@file = file
	end

#this method modifies all the srt times the amount of delay time specified in the parameter
#delay_time must be specified on ms and admit positive and negative numbers
	def time_shift(delay_time)
		@file_content = IO.readlines(@file)
		modified_file = @file_content.map do |line|
			if line.include? " --> "
				time = line.split(' --> ')
				time = time.map do |time| 
					a = DateTime.parse(time)
					a + delay_time.to_i/(24*60*60*1000).to_f 
				end
				line = time[0].strftime("%T,%L") + " --> " + time[1].strftime("%T,%L")
			else
				line
			end	
		end
		@file_content = modified_file
		IO.write(@file, modified_file)
	end

#this method creates a file with the words of the subtitles not included in the Unix dictionary
#destination file defines the file that is going to write the result of the function 
	def typos_in_file(destination_file)

		subtitles_object_list = get_subtitle_objects_in_file

		lines = get_lines(subtitles_object_list)

		words = get_words(lines)

		typos = word_not_in_dictionary(words)

		typos_list = look_for_typos_in_file(typos, subtitles_object_list)

		typos_file_content = {}
		typos_list.each do |typos_object|
			typos_file_content.merge!(typos_object) {|k,l,r| [l,r].flatten.join(", ") }
		end

		content = ""
		typos_file_content.each do |word|
			content << word[0] + ": " + word[1] + "\n"
		end
		IO.write(destination_file, content)
	end

#this method censores all the words provided in the file  until the time specified as parameter
	def profanity_filter(time, profanity_filter)
		censored_words = IO.read(profanity_filter).split("\n").each { |w| w.gsub!("\n","") }

		subtitles_object_list = get_subtitle_objects_in_file

		modified_subtitles = modify_subtitles(time, censored_words, subtitles_object_list)
		
		#print modified subtitles in a file
		file_content = get_text_from_subtitles(modified_subtitles)
		IO.write(@file, file_content)
	end


#auxiliar methods
	def modify_subtitles(time, censored_words, subtitles_object_list)
		modified_subtitles = subtitles_object_list.map do |subtitle|
			if subtitle.time1[3..4].to_i < time.to_i
				mod_sub = modify_subtitle_item_text(subtitle, censored_words)
			else
				mod_sub = subtitle
			end
		end
		modified_subtitles
	end

	def modify_subtitle_item_text(subtitle, censored_words)
		mod_sub = subtitle.text.map do |text|
			censored_words.each do |word|
				censor = word.gsub(/./,"*")
				text.gsub!( word, censor )
			end
			subtitle
		end
		mod_sub.last
	end

	def get_file_content
		IO.read(@file).gsub(/\r/,"")
	end

	def get_subtitle_objects_in_file
		@file_content = get_file_content
		
		subtitles_object_list = @file_content.split("\n\n").map do |item|
			Subtitle.new(item.split("\n"))
		end
		subtitles_object_list
	end

	def get_text_from_subtitles(subtitles_object)
		content = []
		file_content = subtitles_object.map do |subtitle|
			content = subtitle.index + "\n" + subtitle.time1 + " --> " + subtitle.time2 + "\n"
			subtitle.text.map do |text| 
				content << text + "\n" 
			end
			content
		end
		file_content.join("\n")
	end

	def get_lines(subtitles_list)
		lines = []
		subtitles_list.map do |subtitle_item|
			lines.concat(subtitle_item.text)
		end
		lines
	end

	def get_words(lines)
		words = []
		lines.map do |line|
			words.concat(line.gsub('<i>',"").gsub('</i>',"").gsub(/[-":;,.!?=]/,"").downcase.split(" "))
		end
		words
	end

	def get_dictionary
		IO.readlines("/usr/share/dict/words").map{ |dict_word| dict_word.gsub(/\n/,"").downcase }
	end

	def word_not_in_dictionary(words)
		dictionary = get_dictionary
		result = []
		words.each do |word|
			unless dictionary.include? word.downcase 
				result << word
			end
		end
		result.uniq!
	end

	def look_for_typos_in_file(typos, subtitles_object_list)
		typos_list =[]
		typos.each do |word|							#words
			subtitles_object_list.map do |subtitle|    #subtitles_texts
				subtitle.text.each do |text|		#subtitles_phrases
					if text.downcase.include? word
						typos_list << { word => subtitle.time1 }
					end
				end
			end
		end
		typos_list
	end
end

class Subtitle
	attr_accessor :index, :time1, :time2, :text
	def initialize(array)
		times = array[1].split(" --> ")
		@index = array[0]
		@time1 = times[0]
		@time2 = times[1]
		@text = array[2..array.length]
	end
end

#EXAMPLES OF THE CODE NECESARY TO RUN THE METHODS
subtitles = SrtProccess.new("GOTshort.srt")

#to run the time_shift method
#subtitles.time_shift(500)

#to run the typos_in_file method
#subtitles.typos_in_file("potential_typos.txt")

#to run the profanity_filter method
subtitles.profanity_filter(10, "censored_words.txt")