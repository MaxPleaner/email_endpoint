require 'socket' # from Ruby Std-lib, provides TCPServer

# Runs a server in a background thread and closes it when the block is done
# @yield [base_url]
# @return [void]
def with_running_server(&blk)
  port = find_open_port
  thread = Thread.new { `rackup -p #{port} &> /dev/null` }
  sleep 1 # TODO: remove this
  blk.call("http://localhost:#{port}")
  thread.kill
end

private

# @return port_number [Integer] which is available for a TCP server to use
#   Thanks to https://stackoverflow.com/a/201528/2981429 for this 
def find_open_port
  server = TCPServer.new('127.0.0.1', 0)
  server.addr[1].to_i.tap { server.close }
end