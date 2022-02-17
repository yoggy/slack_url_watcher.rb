#!/usr/bin/ruby
# vim: expandtab ts=2 sw=2 :
require 'openssl'
require 'open-uri'
require 'pp'
require 'json'
require 'logger'
require 'pstore'

$stdout.sync = true
Dir.chdir(File.dirname($0))
$current_dir = Dir.pwd

$log = Logger.new('log.txt', 'monthly')
$log.level = Logger::DEBUG

$target_url = "http://example.com/"
#$target_url = "http://example.com/aaa"
#$$target_url = "http://not-found-domain-abae2577def206e82056f4694f61ddf7.com/"
$webhook_url = "https://hooks.slack.com/services/xxxxxxxxxxxxxxxxx/xxxxxxxxxxxxxxxxxxxx"

$db = PStore.new("./db.pstore")

def check_ignore_time
  t = nil

  $db.transaction do
    t = $db["last_update_time"]
  end
  t = DateTime.new(1970, 1, 1, 0, 0, 0) if t.nil?

  diff = DateTime.now.to_time - t.to_time

  if diff.to_f < 24 * 60 * 60
    return false
  end

  true
end

def update_time
  $db.transaction do
    $db["last_update_time"] = DateTime.now
  end
end

def clear_time
  $db.transaction do
    $db["last_update_time"] = DateTime.new(1970, 1, 1, 0, 0, 0)
  end
end

def kick_slack_webhook(message)
  h = {:text => message}
  json_str = h.to_json
  puts json_str

  cmd = "curl -s -X POST -H 'Content-Type: application/json' -d '#{json_str}' #{$webhook_url}"
  puts cmd
  system(cmd)
end

def main
  begin
    URI.open($target_url, {:ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE, :read_timeout => 7}).read
    $log.info "SUCCESS: url=#{$target_url}"
    clear_time
  rescue => e
  	message = "ERROR: url=#{$target_url}, err=#{e}"
    $log.error(message)
  
    if check_ignore_time
      kick_slack_webhook(message)
      update_time
    end
  
  end
end

if __FILE__ == $0
  main
end
