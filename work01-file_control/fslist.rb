#!/usr/bin/evn ruby
#coding: utf-8
##------------------------------------------------------------------------------------------------
require "optparse"
##------------------------------------------------------------------------------------------------

## Input
option = {}
OptionParser.new do |opt|
  opt.on('-b branch', '--branch=branch', 'master | gm1.8') { |v| option[:branch] = v }
  opt.parse!(ARGV)
end
p option

root = ""
webapp_path = ""

if option[:branch] == "master"
  root = ENV['P4PATH_12G_BASELINE']
elsif option[:branch] == "gm1.8"
  root = ENV['P4PATH_12G_MP']
else
  puts "Please input param [master | gm1.8]"
  print "Exit"
  exit
end

webapp_path = root + "/WebBrowser/WebApp"
tmp_file = webapp_path + "/tmp_fslist.txt"
puts "root = #{root}"
puts "webapp = #{webapp_path}"
puts "tmp_file = #{tmp_file}"

# make tmp file
%x[rm -rf #{tmp_file}]
%x[find #{webapp_path}"/app" > #{tmp_file}]
%x[sed -i -e 's!/home.*/WebApp/app!./etc/www/app!' #{tmp_file}]

