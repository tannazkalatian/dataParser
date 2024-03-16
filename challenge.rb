require 'json'
require 'set'

# first we want to make sure the files are parsable and processable.
def load_json(file_path)
  begin
    file = File.read(file_path)
    JSON.parse(file)
  rescue StandardError => e
    puts "Error loading #{file_path}: #{e}"
    []
  end
end

# if the user is not acitve or the company id associated to the user doesn't exist in company ids, user is not valid.
def is_valid_user(user, company_ids)
  user['active_status'] == true && company_ids.include?(user['company_id'])
end

def get_company_top_up(user, companies)
  company = companies.find { |c| c['id'] == user['company_id'] }
  company ? company['top_up'] : 0
end

users = load_json('users.json')
companies = load_json('companies.json')

# we can create a lookup hash for company ids for faster processing.
company_ids = companies.map { |company| company['id'] }.to_set

output_lines = []
# here we sort the companies based on company id.
companies.sort_by { |c| c['id'] }.each do |company|
  emailed = []
  not_emailed = []
  total_top_up = 0

  # here we sort the user's based on their last name.
  users.select { |user| is_valid_user(user, company_ids) }.sort_by { |user| user['last_name'] }.each do |user|
    next unless user['company_id'] == company['id']

    top_up = get_company_top_up(user, companies)
    new_token_balance = user['tokens'] + top_up
    total_top_up += top_up

    user_line = "\t\t#{user['last_name']}, #{user['first_name']}, #{user['email']}\n\t\t  Previous Token Balance, #{user['tokens']}\n\t\t  New Token Balance #{new_token_balance}"

    if user['email_status'] == true && company['email_status'] == true
      emailed << user_line
    else
      not_emailed << user_line
    end
  end

  # based on example output, we only proceed if there are active users (either emailed or not emailed).
  next if emailed.empty? && not_emailed.empty?

  output_lines << "\n\tCompany Id: #{company['id']}"
  output_lines << "\tCompany Name: #{company['name']}"
  output_lines << "\tUsers Emailed:"
  output_lines.concat(emailed)
  output_lines << "\tUsers Not Emailed:"
  output_lines.concat(not_emailed)
  output_lines << "\t\tTotal amount of top ups for #{company['name']}: #{total_top_up}\n"
end

File.open('output.txt', 'w') do |file|
  file.puts output_lines
end
