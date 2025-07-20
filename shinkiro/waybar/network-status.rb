#!/usr/bin/env ruby
require 'json'
require 'open3'

def get_network_info
  ethernet_info = ""
  wifi_info = ""
  
  # Check ethernet status
  eth_output, _, eth_status = Open3.capture3("ip -j addr show")
  if eth_status.success?
    interfaces = JSON.parse(eth_output)
    
    # Find ethernet interface (usually starts with 'e')
    eth_interface = interfaces.find { |i| i['ifname'] =~ /^e/ && i['operstate'] == 'UP' }
    if eth_interface && eth_interface['addr_info']
      ipv4 = eth_interface['addr_info'].find { |a| a['family'] == 'inet' }
      ethernet_info = "󰈀 #{ipv4['local']}" if ipv4
    end
    
    # Find WiFi interface (usually starts with 'w')
    wifi_interface = interfaces.find { |i| i['ifname'] =~ /^w/ && i['operstate'] == 'UP' }
    if wifi_interface
      # Get WiFi SSID
      ssid_output, _, ssid_status = Open3.capture3("iwgetid -r")
      if ssid_status.success? && !ssid_output.strip.empty?
        wifi_info = "󰖩 #{ssid_output.strip}"
      else
        wifi_info = "󰖩 N/A"
      end
    else
      wifi_info = "󰖩 N/A"
    end
  end
  
  # Fallback if no ethernet
  ethernet_info = "󰈀 N/A" if ethernet_info.empty?
  
  # Combine both
  text = "#{ethernet_info}  #{wifi_info}"
  
  # Create tooltip with more details
  tooltip_lines = []
  
  # Ethernet details
  eth_details, _, _ = Open3.capture3("ip addr show | grep -E '^[0-9]+: e' -A 3")
  tooltip_lines << "Ethernet:\n#{eth_details.strip}" unless eth_details.empty?
  
  # WiFi details
  wifi_details, _, _ = Open3.capture3("ip addr show | grep -E '^[0-9]+: w' -A 3")
  tooltip_lines << "\nWiFi:\n#{wifi_details.strip}" unless wifi_details.empty?
  
  output = {
    text: text,
    tooltip: tooltip_lines.join("\n"),
    class: "network-status"
  }
  
  puts output.to_json
  
rescue => e
  output = {
    text: "󰈀 Error  󰖩 Error",
    tooltip: "Error: #{e.message}",
    class: "error"
  }
  puts output.to_json
end

# Run the main function
get_network_info if __FILE__ == $0