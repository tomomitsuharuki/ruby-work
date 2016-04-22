require 'rack'
require 'pp'

class RackApplication
  def call(env)
    pp env
    [200, {'Content-Type' => 'text/plain'}, ['Hello!']]
  end
end

use Rack::ShowStatus
use Rack::Auth::Basic do |username, password|
  username == password
end

run RackApplication.new