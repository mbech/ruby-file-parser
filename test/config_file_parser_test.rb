require_relative 'test_helper'
require_relative '../lib/config_file_parser'


# Expose private Class method for testing
class ConfigFileParser
  class << self
    public :process_input_line
  end
end

# Shorthand for class being tested
CFP = ConfigFileParser

describe ConfigFileParser do

  describe "#self.parse" do
    file_path= "test/test_data_input.txt"
    nonexistant_file_path = "test/nope.doc"

    it "returns empty hash if file not found (i.e. new file create)" do
      CFP.parse(nonexistant_file_path).must_equal Hash.new
    end

    it "returns a hash for valid file paths" do
      CFP.parse(file_path).must_be_instance_of Hash
    end

    it "creates the correct section keys" do
      data_hash = CFP.parse(file_path)
      data_hash.keys.length.must_equal 3
      data_hash.keys.first.must_equal "header"
      data_hash.keys.last.must_equal "trailer"
    end

    it "creates keys under the right sections" do
      data_hash = CFP.parse(file_path)
      header_hash = data_hash["header"]
      trailer_hash = data_hash["trailer"]

      header_hash.keys.length.must_equal 3
      header_hash.must_include("project")
      header_hash.must_include("budget")
      header_hash.must_include("accessed")
      trailer_hash.keys.length.must_equal 1
      trailer_hash.must_include("budget")
    end

    it "creates the correct values for single-line key/value pairs" do
      data_hash = CFP.parse(file_path)
      header_hash = data_hash["header"]
      trailer_hash = data_hash["trailer"]

      header_hash["project"].must_equal "Programming Test"
      header_hash["budget"].must_equal 4.5
      header_hash["accessed"].must_equal 205

      trailer_hash["budget"].must_equal "all out of budget." 
    end

    it "creates the correct values for multi-line key/value pairs" do
      data_hash = CFP.parse(file_path)
      meta_data_hash = data_hash["meta data"]
      meta_data_hash["description"].length.must_equal 155
      meta_data_hash["description"].split.size.must_equal 28
      meta_data_hash["description"].split[6].must_equal "of"
      meta_data_hash["description"].split.last.must_equal "mind."
    end
  end

  describe "#self.process_input_line" do
    section_line = "[   section 1     ]   "
    invalid_section_line = "->[section Q]" #must start in col 0
    key_flt_line = "key1:2.151"
    key_int_line = "key2   :    42   "
    key_str_line = "third key :apples"
    value_runon_line= "Some more words- [To] 'go' on..."
    blank_line = "       \n  \r   "

    it "handles valid section lines" do
      result = CFP.process_input_line(section_line)
      result.must_equal({ type: :section, data: "section 1" })
    end

    it "handles invalid section line as value" do
      result = CFP.process_input_line(invalid_section_line)
      result.must_equal({ type: :value, data: invalid_section_line })
    end

    it "handles blank lines" do
      result = CFP.process_input_line(blank_line)
      result.must_equal({ type: :blank, data: "" })
    end

    it "handles key strings with float values" do
      result = CFP.process_input_line(key_flt_line)
      result.must_equal({ type: :key, data: {"key1" => 2.151} })
    end

    it "handles key strings with int values" do
      result = CFP.process_input_line(key_int_line)
      result.must_equal({ type: :key, data: {"key2" => 42} })
    end

    it "handles key strings with str values" do
      result = CFP.process_input_line(key_str_line)
      result.must_equal({ type: :key, data: {"third key" => "apples"} })
    end

    it "handles run-on value strings" do
      result = CFP.process_input_line(value_runon_line)
      result.must_equal({ type: :value, data: value_runon_line})
    end
  end
end
