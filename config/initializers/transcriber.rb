require 'open3'
# Transcriber.new.transcribe_audio("audio.mp3") will cause a initialization to close the connection, or to a memory leak
# why? because the Transcriber class is not being used in the application, so the connection is not being closed
# and the memory is not being released.
# to fix this, we need to add a conditional to check if the environment variable WHISPER is true.

class Transcriber
  class NotAvailable < StandardError; end

  def initialize
    return unless ENV["WHISPER"] == 'true'
    @stdin, @stdout, @stderr, @wait_thr =  Open3.popen3("python -u #{Rails.root.join("lib", "main.py")}")
  end

  def transcribe_audio(audio_file)
    raise Transcriber::NotAvailable unless @stdin
    @stdin.puts(audio_file)
    output = ""
    while line = @stdout.gets
      break if line.strip == "___TRANSCRIPTION_END___"
      output += line
    end
    output.strip
  rescue Errno::EPIPE
    @stdin, @stdout, @stderr, @wait_thr =  Open3.popen3("python -u #{Rails.root.join("lib", "main.py")}")
    retry
  end
end

TRANSCRIBER = Transcriber.new
