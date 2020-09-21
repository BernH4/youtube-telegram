require 'telegram/bot'
require 'dotenv/load'
require 'open3'

token = ENV['API_TOKEN']
youtube_regex = /^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$/

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    puts "\nUser input: #{message.text}"
    timer_start = Time.now
    case message.text
    when 'Test'
      bot.api.send_message(chat_id: message.chat.id, text: "Running and working!")
    when youtube_regex
      puts "YouTube link recognized, fetching name"
      bot.api.send_message(chat_id: message.chat.id, text: "YouTube link recognized, fetching name")
      filename = Open3.capture3("youtube-dl", "--get-filename", "-o", '%(title)s.mp3', message.text).first.chomp.tr("\"", "")
  
      puts "Downloading #{filename}"
      bot.api.send_message(chat_id: message.chat.id, text: "Downloading #{filename}")
      stdout_dl, stderr_dl, status_dl = Open3.capture3("youtube-dl", "-x","-o", "/home/pi/Downloads/music/%(title)s.%(ext)s", "--add-metadata", "--xattrs", "--embed-thumbnail", "--audio-format", "mp3", "--audio-quality", "0", message.text)
      bot.api.send_Audio(chat_id: message.chat.id, audio: Faraday::UploadIO.new("/home/pi/Downloads/music/#{filename}", 'audio/mp3'))
      bot.api.send_message(chat_id: message.chat.id, text: "Finished in #{(Time.now - timer_start).truncate} seconds!")
      puts "Finished!"
    end
  end
end


