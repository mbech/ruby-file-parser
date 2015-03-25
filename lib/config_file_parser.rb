class ConfigFileParser
  class << self
    # Parse the given file, returning the data in a nested hash
    def parse(input_filepath)
      # Not loading an existing file, so return a new empty hash
      return {} if !File.exist?(input_filepath)

      # File exists, so load and parse it
      input_file = File.open(input_filepath)
      config_data = create_data_hash(input_file)
      input_file.close

      config_data
    end

    private

    # Constructs a nested hash from the input config file
    def create_data_hash(input_file)
      data_hash = Hash.new
      open_key = nil
      open_section = nil

      # Build up the data_hash with line data, based on line's type
      input_file.each do |line|
        line_hash = process_input_line(line)
        line_data = line_hash[:data]
        line_type = line_hash[:type]

        if line_type == :section && !data_hash[line_data]
        #create new section
            open_section = line_data
            data_hash[open_section] = Hash.new
        elsif line_type == :key && !data_hash[open_section][line_data.keys[0]]
        #create new key
          open_key = line_data.keys[0]
          data_hash[open_section][open_key] = line_hash[:data][open_key]
        elsif line_type == :value && open_section && open_key
        # run-on value, so append to value on currently 'open' key
        data_hash[open_section][open_key] += " #{line_hash[:data]}"
      end
        # ignore the line if :blank or section/key already exists
    end
    data_hash
  end

  # Takes in a line of (config file) text, determines what type it is
  # Returns a hash containing the determined type and cleaned-up data
  # For Example: 
  # input: "[    section 2   ]   "
  # output: { type: :section, data: "section 2" } 
  def process_input_line(line)
    type = identify_line_type(line)
    data = extract_line_data(line, type)
    { type: type, data: data }
  end

  # Evaluates given input string of config file text and returns a symbol
  # representing the 'type' of the line:
  # (blank/section/key/value)
  def identify_line_type(line)
    blank_regex = /\A\s*\z/
    section_regex = /\A\[.+\]/
    # note: key_regex assumes keys can be multi-word, e.g. "all key 1 : val1"
    key_regex = /\A\S.*:/

    case line
    when blank_regex then :blank
    when section_regex then :section
    when key_regex then :key
    else :value
    end
  end

  # Based on the provided type, processes the input line to extract the
  # sanitized data value as a string, float, int, or key-val pair.
  # For Example: 
  # input: ("key1 :    55 ", :key)
  # output: { "key1" => 55 }   #~> a hash object with Fixnum value
  def extract_line_data(line, type)
    bracket_regex = /[\[\]]/
    key_find_regex = /\A\S.*(?=:)/
    value_find_regex = /(?<=:).*/

    case type
    when :section
      data = line.gsub(bracket_regex, "").strip
    when :key
      key = key_find_regex.match(line).to_s.strip
      value = value_find_regex.match(line).to_s
      data = Hash[key, convert_str_to_value(value)] 
    when :value
      data = convert_str_to_value(line)
    else
      data = ""
    end
  end

  # Turns input string into a float or int if possible, otherwise returns string
  def convert_str_to_value(str)
    begin
      if(float = Float(str)) && (float % 1.0 == 0)
        float.to_i 
      else 
        float 
      end
    rescue 
      # If float conversion fails, return stripped original str
      str.strip
    end
  end
end
end
