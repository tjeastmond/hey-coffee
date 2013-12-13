## 0.5.7

Features:
  - Switched some tasks to be async instead of sync
  - Added a test condition to watch for an exception when trying to create a site in a directory that has one already

## 0.5.6

Features:

  - Froze versions of dependent modules
  - Added a changelog
  - Nyan cat love

Bugfixes:

  - Fixed broken tests

## 0.5.2

Features:

  - Pages that now display multiple posts get an "isIndex" variable passed down to template
  - Templates now get a variable called "archiveList" that contains a JSON object of links to monthly landing pages
  - Moved monthly archive index file to "/year/month/index.html" instead of nesting in another directory
