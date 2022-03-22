require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone_number)
    phone_number.gsub!(/[^\d]/,'')
    if phone_number.length > 10 && phone_number[0] == "1"
        phone_number[1..10]
    elsif phone_number.length == 10
        phone_number
    else
        "Invalid Phone Number"
    end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def time_setup()
  time = Time.now

  case(time.wday)
  when 0
    wday = "Sunday"
  when 1
    wday = "Monday"
  when 2
    wday = "Tuesday"
  when 3
    wday = "Wednesday"
  when 4
    wday = "Thursday"
  when 5
    wday = "Friday"
  when 6
    wday = "Saturday"
  end

  case(time.month)
  when 1
    month = "January"
  when 2
    month = "Feburary"
  when 3
    month = "March"
  when 4
    month = "April"
  when 5
    month = "May"
  when 6
    month = "June"
  when 7
    month = "July"
  when 8
    month = "August"
  when 9
    month = "September"
  when 10 
    month = "October"
  when 11
    month = "November"
  when 12
    month = "December"
  else
    month = "Invalid"
  end

  day = time.day

  year = time.year
  
  main_time = time.strftime("%I:%M %p")

  time = "#{wday}, #{month} #{day}, #{year}, #{main_time}"

end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone_number = clean_phone_number(row[:homephone])
  time = time_setup()
  
  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end