#!/usr/bin/evn ruby
#coding: utf-8
##------------------------------------------------------------------------------------------------
require "optparse"
##------------------------------------------------------------------------------------------------

## Input


# root = "";
# webapp_path = "";


# File
tmp_file = "data/tmp.txt";
fs_file = "data/target.txt";

web_app_start = <<"EOS"
#---------------------------------------
# WEB APP
#---------------------------------------
EOS

web_app_end = <<"EOS"
#---------------------------------------
# BROWSER DATA
#---------------------------------------
EOS

tmp_buffer = File.read(tmp_file);
fs_buffer = File.read(fs_file);

# puts tmp_buffer;
# puts fs_buffer;

puts web_app_start;
puts web_app_end;

pos_start = fs_buffer.index(web_app_start) + web_app_start.size;
pos_end = fs_buffer.index(web_app_end);

fs_buffer.slice!(pos_start..pos_end);
fs_buffer.insert(pos_start, tmp_buffer);

File.write("data/target_test.txt", fs_buffer);
