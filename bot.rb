require 'telegram/bot'

token = '1077149743:AAF8h-m2cO80DDmpmnQyUeDfsJOPZsoxWxY'

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Was geht ab, #{message.from.first_name}?")
    when '/mp3'
      bot.api.send_Audio(chat_id: message.chat.id, audio: Faraday::UploadIO.new('/home/pi/test.mp3', 'audio/mp3'))
    end
  end
end
