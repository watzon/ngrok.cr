# To run this example you will need to use the tourmaline
# telegram bot framework. It can be found here
# https://github.com/protoncr/tourmaline

require "ngrok"
require "tourmaline"

class EchoBot < Tourmaline::Client
  @[Command("echo")]
  def echo_command(ctx)
    ctx.message.reply(ctx.text)
  end
end

Ngrok.start(addr: "127.0.0.1:3400") do |ngrok|
  bot = EchoBot.new(ENV["API_KEY"])

  bot.set_webhook(ngrok.ngrok_url_https)
  bot.serve("127.0.0.1", 3400)
end
