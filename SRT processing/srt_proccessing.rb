class SrtProccess
	require 'date'
	def initialize(file)
		@file = file
		@file_content = IO.readlines(@file)
	end

#this method modifies all the srt times the amount of delay time specified in the parameter
#delay_time must be specified on ms and admit positive and negative numbers
	def time_shift(delay_time)
		modified_file = @file_content.map { |line|
			if line.include? " --> "
				time = line.split(' --> ')
				time = time.map { |time| 
					a = DateTime.parse(time)
					a + delay_time.to_i/(24*60*60*1000).to_f 
				}
				line = time[0].strftime("%T,%L") + " --> " + time[1].strftime("%T,%L")
			else
				line
			end	
		}
		IO.write(@file, modified_file)
	end
end

#EXAMPLES OF THE CODE NECESARY TO RUN THE METHODS
subtitles = SrtProccess.new("GOTshort.srt")
subtitles.time_shift(500)
