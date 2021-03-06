# frozen_string_literal: true

require 'bundler/setup'
require 'tipi'
require 'tipi/websocket'

def ws_handler(conn)
  timer = spin_loop(interval: 1) do
    conn << Time.now.to_s
  end
  while (msg = conn.recv)
    conn << "you said: #{msg}"
  end
rescue Exception => e
  p e
ensure
  timer.stop
end

opts = {
  reuse_addr:  true,
  dont_linger: true,
  upgrade:     {
    websocket: Tipi::Websocket.handler(&method(:ws_handler))
  }
}

HTML = IO.read(File.join(__dir__, 'ws_page.html'))

puts "pid: #{Process.pid}"
puts 'Listening on port 4411...'

Tipi.serve('0.0.0.0', 4411, opts) do |req|
  req.respond(HTML, 'Content-Type' => 'text/html')
end
