#!/usr/bin/env ruby
require 'json'
require 'open3'

def get_network_info
  eth_connected = false
  wifi_connected = false
  tooltip_lines = []
  
  # Check network status
  eth_output, _, eth_status = Open3.capture3("ip -j addr show")
  if eth_status.success?
    interfaces = JSON.parse(eth_output)
    
    # Check ethernet interface (enp0s31f6 or similar)
    eth_interface = interfaces.find { |i| i['ifname'] =~ /^(eth|enp|eno|ens)/ }
    if eth_interface
      if eth_interface['operstate'] == 'UP' && eth_interface['addr_info']
        ipv4 = eth_interface['addr_info'].find { |a| a['family'] == 'inet' }
        if ipv4
          eth_connected = true
          tooltip_lines << "Ethernet: Connected (#{ipv4['local']})"
        else
          tooltip_lines << "Ethernet: Connected (no IP)"
        end
      else
        tooltip_lines << "Ethernet: Disconnected"
      end
    else
      tooltip_lines << "Ethernet: Not found"
    end
    
    # Check WiFi interface (wlan0, wlp, etc - but not wwp which is WWAN)
    wifi_interface = interfaces.find { |i| i['ifname'] =~ /^(wlan|wlp)/ }
    if wifi_interface
      if wifi_interface['operstate'] == 'UP'
        # Get WiFi SSID
        ssid_output, _, ssid_status = Open3.capture3("iwgetid -r")
        if ssid_status.success? && !ssid_output.strip.empty?
          wifi_connected = true
          if wifi_interface['addr_info']
            ipv4 = wifi_interface['addr_info'].find { |a| a['family'] == 'inet' }
            if ipv4
              tooltip_lines << "WiFi: #{ssid_output.strip} (#{ipv4['local']})"
            else
              tooltip_lines << "WiFi: #{ssid_output.strip} (no IP)"
            end
          else
            tooltip_lines << "WiFi: #{ssid_output.strip}"
          end
        else
          tooltip_lines << "WiFi: Connected (no SSID)"
        end
      else
        tooltip_lines << "WiFi: Disconnected"
      end
    else
      tooltip_lines << "WiFi: Not found"
    end
  end
  
  # Build status display with colored status indicators
  eth_color = eth_connected ? "#859900" : "#dc322f"
  wifi_color = wifi_connected ? "#859900" : "#dc322f"
  eth_status = eth_connected ? "✓" : "✗"
  wifi_status = wifi_connected ? "✓" : "✗"
  
  text = "󰈀<span color='#{eth_color}'>#{eth_status}</span> 󰖩<span color='#{wifi_color}'>#{wifi_status}</span>"
  
  # Determine overall CSS class
  if eth_connected || wifi_connected
    css_class = "connected"
  else
    css_class = "disconnected"
  end
  
  # Create tooltip - always show both network states
  tooltip = tooltip_lines.join("\n")
  
  output = {
    text: text,
    tooltip: tooltip,
    class: css_class
  }
  
  puts output.to_json
  
rescue => e
  output = {
    text: "󰈀! 󰖩!",
    tooltip: "Error: #{e.message}",
    class: "error"
  }
  puts output.to_json
end

# Run the main function
get_network_info if __FILE__ == $0