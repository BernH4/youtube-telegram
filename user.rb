require_relative 'submethods'
class User
  include Submethods
  attr_accessor :downloads

  def initialize(message)
    @id = message.chat.id
    @namearr = [message.from.first_name, message.from.last_name, message.from.username]
    @fullname = fullname(message.from)
    @known_from = ''
    @downloads = []
    @last_invalid = message
    # @message_log
  end
  
  def not_validated?
    return true if @known_from == ''
  end

  def validate(bot, chatid, message, youtube_regex)
    msgtext = message.text
    if msgtext == '/start' || msgtext =~ youtube_regex
      puts "youtube regex -> nicht validiert"
      bot.api.send_message(chat_id: chatid, text: 'Ungültig, bitte kurz angeben woher du diesen Bot kennst.')
      @last_invalid = message
    else
      @known_from = msgtext
      if @last_invalid.text =~ youtube_regex
        puts "last invalid = #{@last_invalid} ,download youtube"
        bot.api.send_message(chat_id: chatid, text: 'Passt, Download startet jetzt.')
        #Temporary solution to auto download wanted downloads after validation
        return @last_invalid
      else
        puts "last invalid = #{@last_invalid} ,NICHT download youtube"
        bot.api.send_message(chat_id: chatid, text: 'Passt, YouTube Link in den Chat kopieren um Download zu starten.')
      end
    end
  end
end
