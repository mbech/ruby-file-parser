require_relative 'config_file_parser'

class ConfigFile
  attr_accessor :input_file_path, :config_data

  # Initialize instance with existing config file or new file path
  def initialize(file_path)
    @file_path = file_path
    @config_data = ConfigFileParser.parse(file_path)
  end

  # Return the config file value associated with the given section and key
  def get_value(section, key)
    section = @config_data[section]
    section ? section[key] : nil
  end

  # Update/create a config file value with the given section and key
  def set_value(section, key, value)
    section_exists = !!@config_data[section]
    if section_exists
      # Create new key value or update value of existing key
      @config_data[section][key] = value
    else
      # Create section, key, and value
      @config_data[section] = { key => value }
    end
  end

  # Save to new file or overwrite existing file with current config data 
  def write_to_file(output_file_path = @file_path)
    output_file = File.new(output_file_path, "w")
    output_file.write(config_data_string)
    output_file.close
  end

  # Returns formatted string of current config data
  def config_data_string
    config_string = ""

    @config_data.each do |section, keys|
      config_string += "[#{section}]\n"
      keys.each do |key, val|
        config_string += "#{key} : #{val}\n"
      end
      config_string += "\n"
    end
    config_string
  end
end
