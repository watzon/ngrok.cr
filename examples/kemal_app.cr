require "ngrok"
require "kemal"

# Matches GET "http://host:port/"
get "/" do
  "Hello World!"
end

# Creates a WebSocket handler.
# Matches "ws://host:port/socket"
ws "/socket" do |socket|
  socket.send "Hello from Kemal!"
end

Ngrok.start({addr: "127.0.0.1:3400"}) do |ngrok|
  Kemal.run(3400) do
    puts "Your kemal app is live!"
    puts "local: http://127.0.0.1:3400"
    puts "http:  #{ngrok.ngrok_url}"
    puts "https: #{ngrok.ngrok_https_url}"
  end
end
