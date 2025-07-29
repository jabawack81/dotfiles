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
    # Get all metadata in a single call
    metadata, _, metadata_status = Open3.capture3('playerctl', 'metadata', '--format', 
      '{{status}}|{{artist}}|{{title}}|{{position}}|{{mpris:length}}|{{playerName}}|{{xesam:url}}')
    
    # If playerctl fails, no player is running
    unless metadata_status.success?
      output = {
        text: "󰓛",
        tooltip: "No media playing",
        class: "inactive"
      }
      puts output.to_json
      return
    end
    
    # Parse the metadata
    fields = metadata.strip.split('|')
    status = fields[0] || ""
    artist = fields[1] || ""
    title = fields[2] || ""
    position = fields[3] || "0"
    length = fields[4] || "0"
    player_name = fields[5] || "Unknown"
    url = fields[6] || ""
    
    # Detect Plex from URL or player name
    is_plex = player_name.downcase.include?("plex") || 
              url.include?("plex.tv") || 
              url.include?(":32400") ||  # Local Plex server
              player_name == "Plex"
    
    # Set icon based on status - show current state, not action
    icon = case status
           when "Playing" then "󰐊"
           when "Paused" then "󰏤"
           else "󰓛"
           end
    
    # Format output - just show title
    text = if title && !title.empty?
             title
           else
             "Unknown"
           end
    
    # Truncate if too long
    text = text[0..17] + "..." if text.length > 20
    
    # Process time info
    time_info = ""
    if !position.empty? && !length.empty? && length != "0"
      pos_sec = position.to_f.to_i
      len_sec = (length.to_i / 1_000_000)
      time_info = "\n#{format_time(pos_sec)} / #{format_time(len_sec)}"
    end
    
    # Build tooltip with controls info
    tooltip_lines = []
    
    # Add media info
    if artist && !artist.empty?
      tooltip_lines << "Artist: #{artist}"
    end
    tooltip_lines << "Title: #{title || 'Unknown'}"
    tooltip_lines << "Player: #{is_plex ? 'Plex' : player_name}"
    tooltip_lines << "Status: #{status}#{time_info}"
    tooltip_lines << ""
    tooltip_lines << "Controls:"
    tooltip_lines << "• Click: Play/Pause"
    tooltip_lines << "• Scroll Up: Next"
    tooltip_lines << "• Scroll Down: Previous"
    
    tooltip_text = tooltip_lines.join("\n")
    
    output = {
      text: "#{icon} #{text}",
      tooltip: tooltip_text,
      alt: status,
      class: status.downcase
    }
    
    puts output.to_json
    
  rescue => e
    output = {
      text: "󰓛",
      tooltip: e.message,
      class: "error"
    }
    puts output.to_json
  end
end

# Run the main function
get_player_info if __FILE__ == $0