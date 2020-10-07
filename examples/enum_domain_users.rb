#!/usr/bin/ruby

# This example script is used for testing remote service status and start type query.
# It will attempt to connect to a host and query the status and start type of the provided service.
# Example usage: ruby query_service_status.rb 192.168.172.138 msfadmin msfadmin "RemoteRegistry"
# This will try to connect to \\192.168.172.138 with the msfadmin:msfadmin credentialas and get the status and start type of the "RemoteRegistry" service.

require 'bundler/setup'
require 'ruby_smb'

address      = ARGV[0]
username     = ARGV[1]
password     = ARGV[2]
domain       = ARGV[3]
smb_versions = ARGV[4]&.split(',') || ['1','2','3']

sock = TCPSocket.new address, 445
dispatcher = RubySMB::Dispatcher::Socket.new(sock, read_timeout: 60)

client = RubySMB::Client.new(dispatcher, smb1: smb_versions.include?('1'), smb2: smb_versions.include?('2'), smb3: smb_versions.include?('3'), username: username, password: password)
protocol = client.negotiate
status = client.authenticate

puts "#{protocol} : #{status}"

tree = client.tree_connect("\\\\#{address}\\IPC$")
samr = tree.open_file(filename: 'samr', write: true, read: true)

puts('Binding to \\samr...')
samr.bind(endpoint: RubySMB::Dcerpc::Samr)
puts('Bound to \\samr')

puts('[+] SAMR Connect')
server_handle = samr.samr_connect
sid = samr.samr_lookup_domain(server_handle: server_handle, name: domain)
domain_handle = samr.samr_open_domain(server_handle: server_handle, domain_id: sid)

client.disconnect!

