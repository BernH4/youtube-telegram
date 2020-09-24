require 'telegram/bot'
require 'dotenv/load'
require 'open3'
# require 'date'
require_relative 'helper_methods.rb'
include Helpers

token = ENV['API_TOKEN']
music_folder = ENV['MUSIC_FOLDER']
youtube_regex = /^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$/

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    timer_start = Time.now
      bot.api.send_message(chat_id: message.chat.id, text: "MP3 Download funktioniert derzeit nur sehr langsam (schlechte Uploadgeschwindigkeit)")
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Paste YouTube link to convert to mp3")
    when 'Test'
      bot.api.send_message(chat_id: message.chat.id, text: "Funktioniert!")
    when youtube_regex
      bot.api.send_message(chat_id: message.chat.id, text: "YouTube link recognized, fetching name")
      filename = Open3.capture3("youtube-dl", "--get-filename", "-o", '%(title)s.mp3', message.text).first.chomp.tr("\"", "")
      File.write("#{music_folder}log.txt", "#{filename} was downloaded by #{fullname(message.from)} at #{Time.now.strftime("%d.%m.%Y %H:%M")}\n", mode: 'a')
      bot.api.send_message(chat_id: message.chat.id, text: "Downloading #{filename}")
      stdout_dl, stderr_dl, status_dl = Open3.capture3("youtube-dl", "-x","-o", "#{music_folder}%(title)s.%(ext)s", "--add-metadata", "--xattrs", "--embed-thumbnail", "--audio-format", "mp3", "--audio-quality", "0", message.text)
      bot.api.send_Audio(chat_id: message.chat.id, audio: Faraday::UploadIO.new("#{music_folder}#{filename}", 'audio/mp3'))
      bot.api.send_message(chat_id: message.chat.id, text: "Finished in #{(Time.now - timer_start).truncate} seconds!")

      #debuglog
      debuglog = File.open("#{music_folder}debuglog.txt", "a")
      debuglog.puts "\n#{music_folder}debuglog.txt", "#{filename} was downloaded by #{fullname(message.from)} at #{Time.now.strftime("%d.%m.%Y %H:%M")}\n"
      debuglog.puts "\nStandard out:"
      debuglog.puts stdout_dl
      debuglog.puts "\nStandard Error:"
      debuglog.puts stderr_dl
      debuglog.puts "\nStatus:"
      debuglog.puts status_dl
      debuglog.close
    end
  end
end


