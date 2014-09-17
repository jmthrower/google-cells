# GoogleCells

A wrapper for Google's Spreadsheet and Drive APIs.

## Installation

Add this line to your application's Gemfile:

    gem 'google_cells'

## Configuration

Sign up for the Drive API in the [Google developer console](https://console.developers.google.com/project). 

__Oauth 2 Web Flow__

For a web application using the oauth 2 web flow, configure GoogleCells with your client id and secret.

```ruby
GoogleCells.configure do |config|
  config.client_id = 'my-client-id'
  config.client_secret = 'my-client-secret'
end
```

__Oauth 2 Service Account__

For background processing using a service account, configure GoogleCells with your account email, path to your key file, and key secret.

```ruby
GoogleCells.configure do |config|
  config.service_account_email = 'my_service_account@email.here'
  config.key_file = File.dirname(__FILE__) + 
    '/path/to/private-key.file/from/Google'
  config.key_secret = 'notasecret'
end
```

See "examples" directory for implementations of both the web flow and service account in sinatra. To use the examples, add config files with your auth info. to /tmp.

## Usage

```ruby
# list all spreadsheets in account
files = GoogleCells::Spreadsheet.list
files.each do |s|
  p s.title
end

# get spreadsheet by google key
s = GoogleCells::Spreadsheet.get('my-spreadsheet-key-here')

# spread the love
s.share(value:'mybestfriend@email.here', type:'user', role:'writer')

# create a copy of file
c = s.copy

# put spreadsheet in a folder
s.enfold('my-folder-key-here')

# read cell content
w = s.worksheets[0]
w.rows.each do |row|
  row.cells.each do |c|
    p c.value
    p c.input_value
    p c.numeric_value
  end
end

# and write it!
w.rows.from(1).to(2).each do |row|
  row.cells.each do |c|
    c.input_value = "#{cell.row + cell.col}"
  end
end
w.save!

```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/google_cells/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

