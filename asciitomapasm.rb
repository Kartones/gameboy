#!/usr/bin/env ruby

# Class to convert from ASCII-based txt files to GameBoy's Map/BG tile data.
# Generates 20x18 maps inside include files to ease adding them to ASM files .
# Uses my 'tileset.gbr' tiles, so would need changes to make it more generic.
# @author Kartones
class ASCIIToMapASM

	MAX_ROWS = 18
	MAX_COLS = 20
	ASM_VALUES_PER_LINE = 10

	def initialize
		@tiles_mapping = {}
		setup_alphabetic_tiles
		setup_other_tiles
	end

	def create_slides(directory=".")
		valid_files = slide_filenames(directory)
		puts "Add the following to your ASM code:" unless valid_files.length == 0
		valid_files.each { |filename|
			output_filename = [filename.split('.').first, "inc"].join('.').upcase
			data = read_slide(filename)
			store(data, output_filename)
			puts "INCLUDE	\"#{output_filename}\""
		}
	end

	# Make sure file is saved in ASCII/DOS mode (or don't use extended ASCII set/window frame characters)
	def read_slide(filename="slide.txt")
		raise "File #{filename} not found" unless File.exist?(filename)
		processed_lines = []
		count = 0

		file = File.open(filename, "r")
		while (line = file.gets)
			raise "File #{filename} exceeds maximum row size (#{MAX_ROWS})"  if count > MAX_ROWS
			count += 1
			processed_lines.push(process_line(line.force_encoding(Encoding::ASCII_8BIT), count))
		end
		file.close

		#bottom-padding, always MAX_ROWS columns
		if processed_lines.length < MAX_ROWS
			remaining = MAX_ROWS - processed_lines.length
			remaining.times do
				processed_lines.push(process_line(' '))	# will autofill with blanks
			end
		end

		processed_lines.flatten
	end

	def store(contents=[], filename="map_data.inc", section_postfix="_DATA")
		section_name = filename.split('.').first << section_postfix

	  file = File.new(filename, "w")
	  file.write(asm_data(contents, section_name))
	  file.close
	end

	private

	def slide_filenames(directory=".")
		files = []
		Dir.new(directory).each { |file|
			files.push(file) if file.split('.').last == "txt"
		}
		files
	end

	def asm_data(contents, section_name)
		asm_data = "#{section_name}::\n"
		index = 0
		has_more = true

		while has_more
			chunk = contents.slice(index, ASM_VALUES_PER_LINE)
			index += chunk.length
			has_more = contents.length > index

			 asm_data << get_asm_line(chunk) << "\n"
		end

		asm_data
	end

	def get_asm_line(hex_values)
		"DB " << hex_values.map { |value| "$#{value.upcase}" }.join(",")
	end

	def process_line(line, linenum=1)
		processed = []
		count = 0
		line.each_char { |char|
			unless (char.ord == 10 || char.ord == 13)
				raise "Line #{linenum} exceeds maximum column size (#{MAX_COLS}) '#{char.ord}'"  if count > MAX_COLS
				count += 1
				processed.push(process_character(char))
			end
		}

		#right-padding, always MAX_COLS columns
		if processed.length < MAX_COLS
			remaining = MAX_COLS - processed.length
			remaining.times do
				processed.push(process_character(' '))
			end
		end

		processed
	end

	def process_character(char)
		output_char = @tiles_mapping.fetch(char.upcase, 0)
		"%02x" % (output_char > 0 ? output_char : window_char(char))
	end

	# Can't use non-US ASCII (7bit) characters as hash keys, so use a function
	def window_char(char)
		# @see http://www.theasciicode.com.ar/extended-ascii-code/box-drawing-character-single-line-upper-left-corner-ascii-code-218.html
		case char.ord
			when 179 # vert. line
				70
			when 196 # horiz. line
				71
			when 218	# upper left corner
				72
			when 191	# upper right corner
				73
			when 217	# lower right corner
				74
			when 192	# lower left corner
				75
		else
			0
		end
	end

	def setup_alphabetic_tiles
		26.times do |index|
			@tiles_mapping[(index + 65).chr] = index + 1
		end
		10.times do |index|
			@tiles_mapping[(index + 48).chr] = index + 36
		end
	end

	def setup_other_tiles
		@tiles_mapping.merge!({
				'.' => 27,
				',' => 28,
				':' => 29,
				';' => 30,
				'!' => 31,
				'?' => 32,
				'-' => 33,
				'(' => 58,
				')' => 59,
				'[' => 60,
				']' => 61,
				'+' => 62,
				'=' => 63,
				'&' => 64,
				'$' => 65,
				'\'' => 66,
				'"' => 67,
				'/' => 68,
				'|' => 69
			})
	end

end


begin
  generator = ASCIIToMapASM.new.create_slides
end