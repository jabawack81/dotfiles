#!/usr/bin/env ruby
require 'json'
require 'open3'

def format_time(seconds)
  return "0:00" if seconds.nil? || seconds == 0
  minutes = seconds / 60
  secs = seconds % 60
  "#{minutes}:#{secs.to_s.rjust(2, '0')}"
end

def get_player_info
  begin
    # Get player status
    status, status_err, status_status = Open3.capture3('playerctl', 'status')
    
    # If playerctl fails, no player is running
    unless status_status.success?
      output = {
        text: "",
        tooltip: "No media playing",
        class: "inactive"
      }
      puts output.to_json
      return
    end
    
    status = status.strip
    
    # Get metadata
    artist, _, artist_status = Open3.capture3('playerctl', 'metadata', 'artist')
    title, _, title_status = Open3.capture3('playerctl', 'metadata', 'title')
    
    artist = artist.strip if artist_status.success?
    title = title.strip if title_status.success?
    
    # Set icon based on status
    icon = case status
           when "Playing" then "󰏤"
           when "Paused" then "󰐊"
           else "󰓛"
           end
    
    # Format output
    text = if artist && !artist.empty? && title && !title.empty?
             "#{artist} - #{title}"
           elsif title && !title.empty?
             title
           else
             "Unknown"
           end
    
    # Truncate if too long
    text = text[0..31] + "..." if text.length > 35
    
    # Get additional metadata
    player_name, _, _ = Open3.capture3('playerctl', '-l')
    player_name = player_name.strip.split("\n").first || "Unknown"
    
    # Get position and length if available
    position, _, pos_status = Open3.capture3('playerctl', 'position')
    length, _, len_status = Open3.capture3('playerctl', 'metadata', 'mpris:length')
    
    time_info = ""
    if pos_status.success? && len_status.success? && !length.strip.empty?
      pos_sec = position.to_f.to_i
      len_sec = (length.to_i / 1_000_000)
      time_info = "\n#{format_time(pos_sec)} / #{format_time(len_sec)}"
    end
    
    # Build tooltip with controls info
    tooltip_text = [
      "#{artist}",
      "#{title}",
      "Player: #{player_name}",
      "Status: #{status}#{time_info}",
      "",
      "Controls:",
      "• Click: Play/Pause",
      "• Middle Click: Restart track",
      "• Right Click: Stop",
      "• Scroll Up: Next",
      "• Scroll Down: Previous"
    ].join("\n")
    
    output = {
      text: "#{icon} #{text}",
      tooltip: tooltip_text,
      alt: status,
      class: status.downcase
    }
    
    puts output.to_json
    
  rescue => e
    output = {
      text: "",
      tooltip: e.message
    }
    puts output.to_json
  end
end

# Run the main function
get_player_info if __FILE__ == $0