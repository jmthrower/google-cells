+ Don't get a new access token on each request if we already have one.

Version 0.4.0
=========================

+ Added pages to sinatra web flow example
+ Added Spreadsheet#revisions
+ Added Revision class and Revision.list

Version 0.3.0
=========================

+ Added Spreadsheet.subscribe and Spreadsheet.unsubscribe  

Version 0.2.1
=========================

+ Added if-match header to update for new Google sheets compatibility  
  Fixes [GH#2](https://github.com/pikimal/google-cells/issues/2)

Version 0.2.0
=========================

+ Added Spreadsheet#defold to remove from a folder
+ Added explicit title setting to Spreadsheet.copy

Version 0.1.1
=========================

+ Fixed bug in Spreadsheet.delete  
+ Fixed rake default task to run specs  

Version 0.1.0
=========================

+ Added Spreadsheet#delete and Spreadsheet.delete  
  Fixes [GH#1](https://github.com/pikimal/google-cells/issues/1)
