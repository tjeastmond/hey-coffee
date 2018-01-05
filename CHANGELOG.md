## 0.8.0

Features:

  - Updated package dependencies
  - Removed silly Makefile and put scripts in package.json

## 0.7.0

Features:

  - The homepage can now be a static page rather than a blog. In the config file, set 'homepage' to page to make it a static page. Hey-coffee will then look for a index.html in your `pages` directory and make that the home page. You can change the directory your blog post list will be found at by changing the config for `blogDirectory`. It defaults to `blog`
  - If posts or pages have a 'layout' variable, Hey.coffee will use that file for rendering the HTML instead of the default one

## 0.6.0

Features:

  - New layouts/ directory. Default template file will live in this folder for now on
  - If posts or pages have a 'layout' variable, Hey.coffee will use that file for rendering the HTML instead of the default one

## 0.5.9

Bugfixes:

  - Put archive index page generation functionality back. Sorry about that, a test has been written to prevent this from happening again

## 0.5.8

Features:

  - Added a backup command that will create a fresh version of your site and gzips it to a **versions** directory
  - Added tests for new backup functionality
  - Started development of a heavy load (10k posts) test script

Bugfixes:

  - Fixed sync problem when building out pages

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
