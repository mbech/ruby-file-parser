Hello! 

Here's a summary of the structure and some examples of using the
ConfigFile class.

##Structure##

###lib###
There are 2 files, a config_file_parser (only class methods, not to be
instantiated), and a config_file that contains the main ConfigFile class.

The ConfigFile class pulls in the parser, so simply pass ConfigFile.new a new 
or existing file path when creating a ConfigFile instance.  ConfigFile will 
parse and load the existing config data from the file (if any) or set up an empty 
ConfigFile instance if there's nothing to load. The ConfigFile instance can
then be updated, read-from, and written to file using a few instance methods.

###test###
Tests can be run with default 'rake' task within the project dir.  
You may need to run 'bundle install' if rake and/or minitest-reporters gems 
aren't working.  The gems are all just testing-related:
'minitest-reporters' for more colorful/informative test results, 
with rake to easily run all the tests together.

##Using the ConfigFile class##
Here are some examples of using the class to work with config files

require the ConfigFile code (depending on current dir structure)

- require_relative 'lib/config_file'

Initialize with new file path

- cf = ConfigFile.new("new-file.txt")

Alternatley, load up an existing file

- cf = ConfigFile.new("data_files/input.txt")

Add some sections, keys, and values

- cf.set_value("header1", "my key", 55.1)
- cf.set_value("header1", "key2", 10) 
- cf.set_value("header1", "another key", "a value string")
- cf.set_value("header2", "my key", "some data...") 

Look up some values

- value = cf.get_value("header1", "key2") #~> 10

Write it to disk (overwrites if no new path provided)

- cf.write_to_file                     //overwrite
- cf.write_to_file("new-file2.txt")    //write to different file
