# frozen_string_literal: true

module Submethods

  def fullname(user)
    fullname = "#{user.first_name} #{user.last_name}"
    # only append username if the user actually has one
    user.username ? fullname + " (#{user.username})" : fullname
  end

  def youtube_download(bot, chatid, message)
    timer_start = Time.now
    bot.api.send_message(chat_id: chatid, text: 'YouTube link recognized, fetching name')
    filename = Open3.capture3('youtube-dl', '--get-filename', '-o', '%(title)s.mp3', message.text).first.chomp.tr('"', '')
    bot.api.send_message(chat_id: chatid, text: "Downloading #{filename}")
    @debuginfo = Open3.capture3('youtube-dl', '-x', '-o', "#{@music_folder}%(title)s.%(ext)s", '--add-metadata', '--xattrs', '--embed-thumbnail', '--audio-format', 'mp3', '--audio-quality', '0', message.text)
    bot.api.send_Audio(chat_id: chatid, audio: Faraday::UploadIO.new("#{@music_folder}#{filename}", 'audio/mp3'))
    elapsed_time = (Time.now - timer_start).truncate
    @debuginfo << filename << message.from << elapsed_time
    bot.api.send_message(chat_id: chatid, text: "Finished in #{elapsed_time} seconds!")
    File.write("#{@music_folder}log.txt", "#{Time.now.strftime('%d.%m.%Y %H:%M')}: #{fullname(message.from)} downloaded #{filename} in #{elapsed_time}s.\n", mode: 'a')
  end

  def write_debuglog
    debuglog = File.open("#{@music_folder}debuglog.txt", 'a')
    debuglog.puts "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    # debuglog.puts "#{@music_folder}debuglog.txt", "#{@debuginfo[3]} was downloaded by #{fullname(@debuginfo[4])} at #{Time.now.strftime('%d.%m.%Y %H:%M')}\n"
    debuglog.puts "#{Time.now.strftime('%d.%m.%Y %H:%M')}: #{fullname(@debuginfo[4])} downloaded #{@debuginfo[3]} in #{@debuginfo[5]}s.\n"
    debuglog.puts "\nStandard out:"
    debuglog.puts @debuginfo[0]
    debuglog.puts "\nStandard Error:"
    debuglog.puts @debuginfo[1]
    debuglog.puts "\nStatus:"
    debuglog.puts @debuginfo[2]
    debuglog.close
  end

end
