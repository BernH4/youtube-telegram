# TODO: Threads, log only last 3 downloads, delete debug or use class for readability
require 'telegram/bot'
require 'dotenv/load'
require 'open3'
require 'yaml'
require 'pry' # only for debugging
require 'ap'
require_relative 'user'
require_relative 'submethods'

class Messenger
  include Submethods

  def initialize
    @token = ENV['API_TOKEN']
    @music_folder = ENV['MUSIC_FOLDER']
    @my_id = ENV['MY_ID']
    @youtube_regex = /^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$/
    @sleep_regex = /sleep\ ([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/
    @bothead = Telegram::Bot::Client
    @debuginfo = []
    @users = restore_users
  end

  def recieve
    @bothead.run(@token) do |bot|
      bot.listen do |message|
        begin
          message_log(message)
          chatid = message.chat.id
          if !@users.key?(chatid)
            puts "Neuer User wird angelegt"
            bot.api.send_message(chat_id: chatid, text: "Hallo, bitte kurz Angeben wer diesen Bot erstellt hat. (Vorname)\n(Damit ihn nur bekannte nutzen können)")
            @users[chatid] = User.new(message)
            save
            next
          else user = @users[chatid]
          end
          unless user.validated
            user.validate(bot, chatid, message) 
            save
            next
          end
          # bot.api.send_message(chat_id: chatid, text: 'MP3 Download funktioniert derzeit nur sehr langsam (schlechte Uploadgeschwindigkeit)')
          case message.text
          when @youtube_regex
            parsed_message = parse_ytlink(bot, chatid, message) # check if the user sent a playlist link
            youtube_download(bot, chatid, parsed_message) unless parsed_message.nil?
            write_debuglog
            save
          when 'Test'
            bot.api.send_message(chat_id: chatid, text: 'Funktioniert!')
          when @sleep_regex 
            sleeptime_left(message.text.split(/[\ :]/))
          when 'log'
            bot.api.send_message(chat_id: chatid, text: IO.readlines("#{@music_folder}log.txt")[-5..-1].join("~~~~~\n"))
          when 'logall'
            bot.api.send_message(chat_id: chatid, text: File.read("#{@music_folder}log.txt"))
          when 'messagelog'
            bot.api.send_message(chat_id: chatid, text: File.read("#{@music_folder}messagelog.txt")) if chatid == @my_id.to_i
          else 
            bot.api.send_message(chat_id: chatid, text: 'Damit kann ich nichts anfangen.')
          end
          # rescue Telegram::Bot::Exceptions::ResponseError, RuntimeError => e
	  rescue => e
            write_debuglog
	    puts "#{e.class}: #{e.message}"
	    e.backtrace.each { |log| puts log }
            bot.api.send_message(chat_id: chatid, text: 'Etwas ist schief gegangen... Nochmal versuchen.')
            bot.api.send_message(chat_id: @my_id.to_i, text: "#{e.class}: #{e.message}")
            # rescue SocketError, Faraday::ConnectionFailed => e
	  end
      end
    end
  end

  def save
    File.open("#{@music_folder}users.yml", "w") { |file| file.write(@users.to_yaml) }
  end
end

Messenger.new.recieve
