# TODO: Threads
require 'telegram/bot'
require 'dotenv/load'
require 'open3'
require 'pry' # only for debugging
require_relative 'submethods.rb'

class Messenger
  include Submethods

  def initialize
    @token = ENV['API_TOKEN']
    @music_folder = ENV['MUSIC_FOLDER']
    @youtube_regex = /^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?$/
    @bothead = Telegram::Bot::Client
    @debuginfo = []
  end

  def recieve
    @bothead.run(@token) do |bot|
      bot.listen do |message|
        chatid = message.chat.id
        bot.api.send_message(chat_id: chatid, text: 'MP3 Download funktioniert derzeit nur sehr langsam (schlechte Uploadgeschwindigkeit)')
        case message.text
        when '/start'
          bot.api.send_message(chat_id: chatid, text: 'Paste YouTube link to convert to mp3')
        when 'Test'
          bot.api.send_message(chat_id: chatid, text: 'Funktioniert!')
        when 'log'
          bot.api.send_message(chat_id: chatid, text: File.read("#{@music_folder}log.txt"))
        when @youtube_regex
          youtube_download(bot, chatid, message)
          write_debuglog
        end
      end
    end
  end
end

Messenger.new.recieve
