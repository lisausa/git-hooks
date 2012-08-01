#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'net/https'
require 'tempfile'

user = `git config jira.username`.chomp
password = `git config jira.password`.chomp

user and password or raise 'You must set your JIRA credentials'

query = %[assignee = "#{user}" AND status IN (Open,"In Progress",Reopened,Building,"Testing - QA") ORDER BY key]

uri = URI('https://lisausa.atlassian.net/rest/api/2/search')
uri.query = URI.encode_www_form(:jql => query)

request = Net::HTTP::Get.new uri.request_uri
request.basic_auth user, password

response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http|
  http.request(request)
}

data = JSON.parse(response.body)

raise "No file given!" unless ARGV[0]
File.open(ARGV[0], 'r+') do |target_file|
  changes_summary = ''
  # Scan through the lines until we find 'Changes to be committed:'
  until target_file.eof?
    pos = target_file.pos
    if target_file.readline.match(/\A#\s*Changes to be committed/)
      target_file.pos = pos # Rewind back to start of that last line
      changes_summary = target_file.read # Read to the end of the file
      target_file.pos = pos # Put it back there so we can write from this point
      break
    end
  end

  target_file.puts <<-END
#
# Below are your active JIRA Issues (uncomment one or more to attach this commit to it):
# --------------------------------------------------------------------------------------
END

  if data['issues']
    data['issues'].each do |issue|
      target_file.puts '#[%s] - %s' % [issue['key'], issue['fields']['summary']]
    end
  else
    target_file.puts '# !! [ There was an error getting your issues from JIRA ]'
  end
  target_file.puts "#\n#\n#{changes_summary}"
end