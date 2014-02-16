# set this up if you are recording more VCRs
#GoogleCells.configure do |config|
#  config.service_account_email = 'YOUR SERVICE ACCOUNT EMAIL'
#  config.key_file = 'YOUR KEY FILE PATH'
#  config.key_secret = 'YOUR KEY SECRET'
#end
VCR.configure do |c|
  c.filter_sensitive_data('<SERVICE_ACCOUNT_EMAIL>') { 'mysvcaccount@gmail.com' }
  c.filter_sensitive_data('<KEY_FILE>') { '/path/to/a/file' }

  c.filter_sensitive_data('<AUTHOR_EMAIL>') { 'myemail@mydomain.com' }

  c.filter_sensitive_data('<SPREADSHEET_KEY>') { 'myspreadsheetkey' }
  c.filter_sensitive_data('<SPREADSHEET_ID>') { 'myspreadsheetkey' }
  c.filter_sensitive_data('<COPIED_SPREADSHEET_KEY>') { 'copiedspreadsheetkey' }

  c.filter_sensitive_data('<PARENT_KEY>') { 'parentid' }
  c.filter_sensitive_data('<FOLDER_KEY>') { 
    'folderid' }

  c.before_record do |i|
    body = i.response.body
    at = nil
    if body['access_token']
      begin
        at = JSON.parse(body)['access_token']
        VCR.configure do |c|
          c.filter_sensitive_data('<ACCESS_TOKEN>'){ at }
        end
      rescue
      end
    end
  end
end
