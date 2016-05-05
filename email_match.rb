require 'pony'
require 'dotenv'
require 'erb'
require 'csv'

Dotenv.load

def send_email(email_address, email_text, email_html)
  Pony.mail({
    :to => email_address,
    :from => ENV['FROM'],
    :via => :smtp,
    :via_options => {
      :address              => ENV['SMTP_HOST'],
      :port                 => ENV['SMTP_PORT'],
      :enable_starttls_auto => true,
      :user_name            => ENV["SMTP_USERNAME"],
      :password             => ENV["SMTP_PASSWORD"],
      :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
      :domain               => "gmail.com"
      # :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
    },
    :body => email_text,
    :html_body => email_html,
    :subject => "[Yenta]: Your personalized mentor match"
  })
end

def gen_email_text(row)
  @attr = nested_attributes(row)
  @name = row[18]
  ERB.new(File.read("views/match_text.erb")).result
end

def gen_email_html(row)
  @attr = nested_attributes(row)
  @name = row[18]
  ERB.new(File.read("views/match_html.erb")).result
end

def nested_attributes(row)
  attributes = [["Name", row[2..3].join(" ")]]
  attributes += [["Email", row[4]]]
  attributes += [["Class Year", row[5]]]
  attributes += [["Industry", row[6]]] unless row[6] == "[N/A - General]"
  attributes += [["Function", row[7]]] unless row[7] == "[N/A]"
  attributes += [["Location", row[8]]] unless row[8] == "[N/A]"
  attributes += [["Gender", row[10]]] unless row[10].nil?
  unless row[27] == "[No Preference]" or row[11].nil?
    attributes += [["Race / Ethnicity", row[11]]]
  end
  unless row[28] == "[No Preference]"
    attributes += [["LGBT", row[12].nil? ? "N/A" : row[12]]]
  end
  unless row[29] == "[No Preference]"
    attributes += [["Military", row[13].nil? ? "No" : "Yes" ]]
  end
  unless row[30] == "[No Preference]"
    attributes += [["Joint Degree", row[14].nil? ? "N/A" : row[14] ]]
  end
  unless row[31] == "[No Preference]"
    attributes += [["Family Business", row[15].nil? ? "N/A" : row[15] ]]
  end
  return attributes
end

def main
  CSV.parse(File.read("output.csv"), :headers => true).each do |row|
    unless row[20].nil?
      email_address = row[20]
      puts "Sending to #{row[20]} ..."
      puts gen_email_text(row)

      send_email(email_address, gen_email_text(row), gen_email_html(row))
      puts "Sent to: #{row[20]} success!"
      puts "----------------------------"
      sleep rand * 5
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  main
end