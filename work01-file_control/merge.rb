#!/usr/bin/evn ruby
#coding: utf-8
##------------------------------------------------------------------------------------------------
require "pp"
require "optparse"
require "fileutils"
require "find"
##------------------------------------------------------------------------------------------------
WEB_APP_START = <<"EOS"
#---------------------------------------
# WEB APP
#---------------------------------------
EOS

WEB_APP_END = <<"EOS"
#---------------------------------------
# BROWSER DATA
#---------------------------------------
EOS

##------------------------------------------------------------------------------------------------
## Merger Class
class Merger
  def initialize(branch)
    @branch = branch;
    @export_dir = "";
    @repo = "";
    @repo_ = "";
    @root = "";
    @webapp = "";
    @last_commit = "";
    select_branch();
  end

  ## Select Branch
  def select_branch
    if @branch == "master"
      @export_dir = "export" + "/master";
      @repo = "origin/master";
      @repo_ = "origin/release/bdre12g/gm1.8";
      @root = ENV['P4PATH_12G_BASELINE']
    elsif @branch == "gm1.8"
      @export_dir = "export" + "/release_gm1.8";
      @repo = "origin/release/bdre12g/gm1.8";
      @repo_ = "origin/master";
      @root = ENV['P4PATH_12G_MP']
    else
      puts "Please input param [master | gm1.8]"
      puts "Error Exit!"
      exit
    end

    if @root.nil? || @root.empty?
      puts "Please set the P4 environment variable [ P4PATH_12G_BASELINE or P4PATH_12G_MP ].";
      puts "ex) export P4PATH_12G_BASELINE=~/UNI-SYSTEM-RE/BASELINE/";
      error_exit();
    end
    @webapp = @root + "/WebBrowser/WebApp";
    puts "Select [#{@repo}] to [#{@root}]";
  end

  ## Pre-Check P4 Opened
  def p4_pre_check
    puts "pre-check p4 opened";
    opened = %x[p4 opened];
    if !opened.empty?
      puts "Error! There is the file which is in an open state.";
      puts opened;
      error_exit();
    end
    puts "OK";
  end

  ## P4 Sync
  def p4_sync
    # puts %x[echo p4 sync #{@webapp}"/..."]
    puts %x[p4 sync #{@webapp}"/..."]
  end

  ## Load Last Commit
  def load_last_commit
    File.open(@webapp + "/LAST_COMMIT") do |file|
      @last_commit = file.readline.split(" ")[2];
      puts "Last Commit: #{@last_commit}";
    end
  end

  ## Export
  def export_form_git
    FileUtils.rm_rf(@export_dir);
    FileUtils.mkdir(@export_dir);
    ## git archive
    %x[git archive --worktree-attributes --format=tar #{repo} app LAST_COMMIT > #{@export_dir}/app.tar];
    echo "Finish archive! export to [#{export_dir}]"
  end

  ## Output Git Changes
  def output_change_info_git
    git_change_info = "----- change log -----";
    git_change_info += %x[git log --grep "Merge pull request" --pretty=format:'commit: %h %x0A%ci %x0A  %s%x0A  %b%-' #{@last_}..#{@repo}];
    git_change_info += "----- change files -----";
    git_change_info += %x[git diff --name-status #{@last_commit}...#{@repo}];
    File.write(@export_dir + "/change_info_git.txt", git_change_info);
  end

  ## Merge
  def p4_edit_for_merge
    
  end

  ## Output P4 Chenges
  def output_change_info_p4
    
  end

  ## rootfs-list
  def make_fslist
    # add_files = %x[p4 opened | grep "add default change"];
    # return if $?
    # puts "!!!!! There is an additional file!!!!!"
    # puts add_files;

    ## create temp list
    app_list = [];
    Find.find("/Users/tomomitsu/Google ドライブ/Home/ruby-work/work01-file_control") do |file|
      # next unless FileTest.file?(file);
      fs_file = file.sub(%r{^.*/work01-file_control}, "./etc/www/app");
      app_list.push(fs_file);
    end
    pp app_list;

    ## update rootfs-list
    # fs_list_txt = "#{root}/Tools/Target/rootfs-list.txt";
    # %x[p4 edit #{fs_list_txt}];
    fs_list_txt = "data/target.txt";
    fs_list = File.read(fs_list_txt);
    pos_start = fs_list.index(WEB_APP_START) + WEB_APP_START.size;
    pos_end = fs_list.index(WEB_APP_END) - 1;
    # p pos_start;
    # p pos_end;
    tmp_buffer = app_list.join("\n")+"\n";
    # tmp_buffer = %{test \n test};
    puts tmp_buffer;
    fs_list.slice!(pos_start..pos_end);
    fs_list.insert(pos_start, tmp_buffer);
    File.write(fs_list_txt, fs_list);    
  end

  ## LAST_COMMIT
  def update_last_commit
    
  end

  ## Submit
  def p4_submit
    
  end

  ## Backup
  def backup_change_info
    
  end

  ## Auto Mail
  def create_message
  end

  def send_mail
    
  end

  ## Last Message
  def error_exit
    puts "Error Exit";
    exit;
  end

  def finish
    puts "#########################"
    puts "  Finish"
    puts "#########################"
  end
end

##------------------------------------------------------------------------------------------------
## Input
option = {}
OptionParser.new do |opt|
  opt.on('-b branch', '--branch=branch', 'master | gm1.8') { |v| option[:branch] = v }
  opt.parse!(ARGV)
end
p option

##------------------------------------------------------------------------------------------------
## Merge
merger = Merger.new(option[:branch]);
# merger.p4_pre_check();
# merger.p4_sync();
# merger.load_last_commit();
merger.make_fslist();

merger.finish();