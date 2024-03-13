require 'json'

#Parsing the info from JSON files
users = JSON.parse(File.read('users.json'))
companies = JSON.parse(File.read('companies.json')).sort_by { |company| company['id'] }

File.open('output.txt', 'w') do |file|
  companies.each do |company|
    emailed, not_emailed = [], []
    total_top_up = 0

    # Finding active users for the current company based on each company
    active_users = users.filter { |user| user['company_id'] == company['id'] && user['active_status'] }
    active_users.sort_by! { |user| user['last_name'] }

    active_users.each do |user|
      new_token_balance = user['tokens'] + company['top_up']
      user_info = "#{user['last_name']}, #{user['first_name']}, #{user['email']}\n  Previous Token Balance, #{user['tokens']}\n  New Token Balance #{new_token_balance}"

      if user['email_status'] && company['email_status']
        emailed << user_info
      else
        not_emailed << user_info
      end

      total_top_up += company['top_up']
    end

    # At the end writing company information to the file
    file.puts "Company Id: #{company['id']}"
    file.puts "\tCompany Name: #{company['name']}"
    file.puts "\tUsers Emailed:"
    emailed.each { |info| file.puts "\t\t#{info}" }
    file.puts "\tUsers Not Emailed:"
    not_emailed.each { |info| file.puts "\t\t#{info}" }
    file.puts "\tTotal amount of top ups for #{company['name']}: #{total_top_up}"
    file.puts
  end
end
