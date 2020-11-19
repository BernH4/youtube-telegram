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
        ap @users
        chatid = message.chat.id
        if !@users.key?(chatid)
          p "Neuer User wird angelegt"
          bot.api.send_message(chat_id: chatid, text: 'Hallo, bitte kurz angeben woher du diesen Bot kennst um starten zu können:')
          @users[chatid] = User.new(message)
          save
          next
        else user = @users[chatid]
        end
        if user.not_validated?
          tempsolution = user.validate(bot, chatid, message, @youtube_regex)
          youtube_download(bot, chatid, tempsolution.text) if tempsolution.text.match?(@youtube_regex)
          save
          next
        end
        p "user ist validiert"
        # record_user(message)
        message_log(message)
        # bot.api.send_message(chat_id: chatid, text: 'MP3 Download funktioniert derzeit nur sehr langsam (schlechte Uploadgeschwindigkeit)')
        case message.text
        when @youtube_regex
          youtube_download(bot, chatid, message)
          # write_debuglog
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
        end
      end
    end
  end

  def save
    File.open("#{@music_folder}users.yml", "w") { |file| file.write(@users.to_yaml) }
  end
end

Messenger.new.recieve
