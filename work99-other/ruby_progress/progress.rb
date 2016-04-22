#!/usr/bin/env ruby
# coding: utf-8
$stdout.sync = true #書いておかないと出力がバッファに溜め込まれるかも

def progress_bar(i, max = 100)
  i = max if i > max
  rest_size = 1 + 5 + 1      # space + progress_num + %
  bar_width = 49 - rest_size # (width - 1) - rest_size = 72
  percent = i * 100.0 / max
  bar_length = i * bar_width.to_f / max
  bar_str = ('#' * bar_length).ljust(bar_width)
  # bar_str = '%-*s' % [bar_width, ('#' * bar_length)]
  progress_num = '%3.1f' % percent
  # print "\r#{bar_str} #{'%5s' % progress_num}%"
  print "\r[#{bar_str}] #{'%5s' % progress_num}%"
end

(0..1000).each do |j|
  sleep 0.001
  progress_bar(j, 1000)
end
puts
