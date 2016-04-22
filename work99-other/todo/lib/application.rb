# coding: utf-8

require 'sinatra/base'
require 'haml'

require 'todo/db'
require 'todo/task'

module Todo
  class Application < Sinatra::Base
    
    configure do
      DB.prepare
    end

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader
    end

    get '/' do
      redirect '/tasks'
    end

    get '/tasks' do
      @tasks = Task.all
      # 'todo application'
      haml :index
    end
    
  end  
end