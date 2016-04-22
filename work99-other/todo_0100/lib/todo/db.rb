# coding: utf-8

require "fileutils"
require 'active_record'

module Todo

	#モジュール：データベース接続処理
	module DB

		# データベース接続とテーブル作成
		def self.prepare
			database_path = File.join(ENV["HOME"], ".todo", "todo.sqlite3")

			connect_database(database_path)
			create_table_if_not_exits(database_path)
		end

		def self.connect_database(path)
			spec = {adapter: "sqlite3", database: path}
			ActiveRecord::Base.establish_connection(spec)
		end

		def self.create_table_if_not_exits(path)
			create_database_path(path)

			connection = ActiveRecord::Base.connection

			return if connection.table_exists?(:tasks)

			connection.create_table :tasks do |t|
				t.column :name,			:string,								null: false
				t.column :content,	:string,								null: false
				t.column :status,		:integer,		default: 0,	null: false
				t.timestamps
			end
			connection.add_index :tasks, :status
			connection.add_index :tasks, :created_at
		end

		def self.create_database_path(path)
			FileUtils.mkdir_p File.dirname(path)
		end

		private_class_method :connect_database, :create_table_if_not_exits, :create_database_path	
	end

end