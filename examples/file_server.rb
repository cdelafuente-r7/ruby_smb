#!/usr/bin/ruby

require 'bundler/setup'
require 'optparse'
require 'ruby_smb'

# we just need *a* default encoding to handle the strings from the NTLM messages
Encoding.default_internal = 'UTF-8' if Encoding.default_internal.nil?

options = RubySMB::Server::Cli.parse(defaults: { share_path: '.' }) do |options, parser|
  parser.banner = "Usage: #{File.basename(__FILE__)} [options]"

  parser.on("--share-path SHARE_PATH", "The path to share (default: #{options[:share_path]})") do |path|
    options[:share_path] = path
  end
end

server = RubySMB::Server::Cli.build(options)
server.add_share(RubySMB::Server::Share::Provider::Disk.new(options[:share_name], options[:share_path]))

server.register_callback(
  RubySMB::SMB2::Packet::CreateRequest,
  Proc.new { |processor, request|
    puts "in callback for Create request"
    puts "share access: #{request.share_access.to_binary_s.unpack1('V')}"
    request
  }
)

server.register_callback(
  RubySMB::SMB2::Packet::ReadResponse,
  Proc.new { |processor, response|
    puts "in callback for Read response"
    new_file_content = "foobar"
    response.data_length = new_file_content.length
    response.buffer = new_file_content
    response
  }
)

RubySMB::Server::Cli.run(server)
