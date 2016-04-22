# coding: utf-8

require 'optparse'

module Todo
	class Command
		module Options

			def self.parse!(argv)
				options = {}

				# サブコマンドなどのOptionParserを定義
				sub_command_parses = create_sub_command_parsers(options)
				command_parser = create_command_parser

				# 引数の解析を行う
				begin
					command_parser.order!(argv)

					options[:command] = argv.shift

					sub_command_parses[options[:command]].parse!(argv)

					# updateとdeleteの場合はidを取得する
					if %w(update delete).include?(options[:command])
						raise ArgumentError, "#{options[:command]} is not found." if argv.empty?
						options[:id] = Integer(argv.first)
					end
				rescue OptionParser::MissingArgument, OptionParser::InvalidOption, ArgumentError => e
					abort e.message
				end

				return options
			end

			def self.create_sub_command_parsers(options)
				# サブコマンドの処理をする際に、未定義のkeyを指定されたら例外を発生させる
				sub_command_parses = Hash.new do |k, v|
					raise ArgumentError, "'#{v}' is not todo sub command."
				end

				# サブコマンド用の定義
				create_value = OptionParser.new do |opt|
					opt.banner = 'Usage: create <args>'
					opt.on('-n VAL', '--name=VAL',		'task name')			{|v| options[:name] = v }
					opt.on('-c VAL', '--content=VAL', 'task content')		{|v| options[:content] = v }
					opt.on_tail('-h', '--help', 'Show this message')	{|v| help_sub_command(opt)}
				end
				sub_command_parses['create'] = create_value

				search_valus = OptionParser.new do |opt|
					opt.banner = 'Usage: list <args>'
					opt.on('-s VAL', '--status=VAL', 'seach status') {|v| options[:status] = v }
					opt.on_tail('-h', '--help', 'Show this message')	{|v| help_sub_command(opt)}
				end
				sub_command_parses['search'] = search_valus
				sub_command_parses['list'] = search_valus

				update_value = OptionParser.new do |opt|
					opt.banner = 'Usage: update id <args>'
					opt.on('-n VAL', '--name=VAL',    'update name')		  {|v| options[:name] = v }
					opt.on('-c VAL', '--content=VAL', 'update content')		{|v| options[:content] = v }
					opt.on('-s VAL', '--status=VAL',  'update status')		{|v| options[:status] = v }
					opt.on_tail('-h', '--help', 'Show this message')	{|v| help_sub_command(opt)}
				end
				sub_command_parses['update'] = update_value

				sub_command_parses['delete'] = OptionParser.new do |opt|
					opt.banner = 'Usage: delete id'
					opt.on_tail('-h', '--help', 'Show this message')	{|v| help_sub_command(opt)}
				end

				return sub_command_parses
			end

			def self.help_sub_command(parser)
				puts parser.help
				exit
			end

			def self.create_command_parser
				OptionParser.new do |opt|
					sub_command_help = [
					  {name: 'create -n name -c content', 							summary: 'Create Todo task'},
					  {name: 'update id -n name -c content -s status', 	summary: 'Update Todo task'},
					  {name: 'list -s status', 													summary: 'List 	 Todo tasks'},
					  {name: 'delete id', 															summary: 'Delete Todo task'}
					]
					opt.banner = "Usage: #{opt.program_name} [-h|--help] [-v|--version] <command> [<args>]"
					opt.separator ''
					opt.separator "#{opt.program_name} Available Commands:"
					sub_command_help.each do |command|
						opt.separator [opt.summary_indent, command[:name].ljust(40), command[:summary]].join(' ')
					end

					opt.on_head('-h', '--help', 'Show this message') do |v|
						puts opt.help
						exit
					end

					opt.on_head('-v', '--version', 'Show program version') do |v|
						opt.version = Todo::VERSION
						puts opt.ver
						exit
					end
				end
			end

			private_class_method :create_sub_command_parsers, :create_command_parser, :help_sub_command
		end
	end
end