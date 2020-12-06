require_relative 'submethods'
class User
  include Submethods
  attr_accessor :validated, :downloads

  def initialize(message)
    @id = message.chat.id
    @namearr = [message.from.first_name, message.from.last_name, message.from.username]
    @fullname = fullname(message.from)
    @validated = false
    @downloads = []
    # @message_log
  end

  def validate(bot, chatid, message)
    msgtext = message.text
    # if msgtext == '/start'
    #   puts "youtube regex -> nicht validiert"
    #   bot.api.send_message(chat_id: chatid, text: 'Bitte zuerst Namen des Bot Erstellers angeben.')
    if msgtext.downcase.include?('bern')
      @validated = true
      puts 'Erstellername richtig erkannt, validiert!'
      bot.api.send_message(chat_id: chatid, text: 'Passt, YouTube link kann jetzt geschickt werden.')
    else
      puts "Erstellername NICHT in der Nachricht gefunden:\n#{msgtext}"
      bot.api.send_message(chat_id: chatid, text: 'Erstellername NICHT in der Nachricht gefunden. Neuer Versuch?..')
    end
  end
end
