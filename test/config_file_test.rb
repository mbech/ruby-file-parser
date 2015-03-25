require_relative 'test_helper'
require_relative '../lib/config_file'

# Shorthand for class being tested
CF = ConfigFile

describe ConfigFile do
  file_path= "test/test_data_input.txt"
  nonexistant_file_path = "test/nope.doc"

  describe "#initialize" do
    before do
      @cf = CF.new(file_path)
      @new_cf = CF.new(nonexistant_file_path)
    end

    it "stores the parsed config data (existing file or new)" do
      @new_cf.config_data.must_equal Hash.new

      @cf.config_data.must_be_instance_of Hash
      @cf.config_data.must_include "header"
      @cf.config_data["header"].must_include "budget"
      @cf.config_data["header"]["budget"].must_equal 4.5
    end
  end

  describe "#get_value" do
    before do
      @cf = CF.new(file_path)
    end

    it "returns nil for nonexistant section or key" do
      @cf.get_value("no_such_section", "budget").must_be_nil
      @cf.get_value("header", "no_such_key").must_be_nil
    end

    it "gets correct value for valid key" do
      @cf.get_value("header", "budget").must_equal 4.5
      @cf.get_value("header", "accessed").must_equal 205 
      @cf.get_value("trailer", "budget").must_equal "all out of budget."
    end
  end

  describe "#get_value" do
    before do
      @cf = CF.new(file_path)
    end

    it "updates existing value if key already exists" do
      @cf.set_value("header", "budget", "newVal")
      @cf.config_data["header"]["budget"].must_equal "newVal"
    end

    it "creates new key and value if key doesn't already exist" do
      @cf.set_value("header", "budget2", "new val")
      @cf.config_data["header"]["budget2"].must_equal "new val"
      @cf.set_value("trailer", "budget", 99.9)
      @cf.config_data["trailer"]["budget"].must_equal 99.9
    end

    it "creates new section, key, and value if none exist" do
      @cf.set_value("new section", "new key", "new val")
      @cf.config_data.keys.length.must_equal 4
      @cf.config_data["new section"]["new key"].must_equal "new val"
    end
  end

  describe "#write_to_file" do
    new_file_path = 'test/new_file.txt'

    before do
      @cf = CF.new(file_path)
    end

    it "can save to a new file" do
      @cf.write_to_file(new_file_path)
      File.file?(new_file_path).must_equal true
      File.delete(new_file_path)   
    end

    it "can write a new config file from scratch" do
      nonexistant_file_path = "test/new.txt"
      File.file?(nonexistant_file_path).must_equal false
      @new_cf = CF.new(nonexistant_file_path)
      @new_cf.write_to_file
      File.file?(nonexistant_file_path).must_equal true
      File.delete(nonexistant_file_path)   
    end

    it "can overwrite input file with updates" do
      overwrite_path = 'test/overwrite_test.txt'
      @cf_overwrite = CF.new(overwrite_path)
      @cf_overwrite.config_data["header2"]["budget"].must_equal 9.5
      @cf_overwrite.set_value("header2", "budget", 42)
      @cf_overwrite.write_to_file(overwrite_path)
      # reopen file and check for saved change
      @cf_overwrite = CF.new(overwrite_path)
      @cf_overwrite.config_data["header2"]["budget"].must_equal 42 

      # revert change for next test run
      @cf_overwrite.set_value("header2", "budget", 9.5)
      @cf_overwrite.write_to_file(overwrite_path)
    end
  end
end
