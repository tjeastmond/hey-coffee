# Hey.coffee

**These docs are a work in progress**

This is a simple flatfile blog tool. Write your posts with Markdown, and publish via the commandline.

Just to be clear, this blog tool isn't for you if you need a CMS with more features then you'll ever know about. There is no web based interface. Hey.coffee generates flat HTML files, and then rsyncs those files to your web server.

Generated files are placed in the **site/** folder. Anything you place there, including additional folders and files, will be sent up to your server.

Once you have Hey.coffee installed, you can open a shell and run the following command to get info on how to use it:

	> hey --help

## Installing

Coming soon...will be npm.

### Requirements

Hey.coffee was written in...CoffeeScript. So the basic requirements to run this on your personal machine are:

- Node.js
- CoffeeScript installed globally (npm install -g coffee-script)

You will of course need a webserver somewhere for Hey.coffee to post your generated website to. That host should allow you access to rsync.

## Getting Started

To setup a new blog, create an empty directory and run this command:

	> hey --init

This script will generate the base structure of your new blog:

- Posts directory: Save your Markdown posts here. A sample is created by the init command
- Pages directory: Save your pages here
- hey-config.json: Open this file and configure it. More on this to follow
- hey-cache.json: Hey.coffee uses this file to store your processed posts

### hey-config.json

So in this file we have some pretty basic parameters that need setting:

- **siteTitle:** The name of your blog
- **author:** Your name as it will appear in your rss feed
- **description:** Your site's description as it will appear in your rss feed
- **site:** Your site's URL. Should include 'http://' and have no trailing slash
- **postsOnHomePage:** The number of posts on your home page
- **server:** For the rsync: user@yoursite.com:/path/to/blog
- **port:** The ssh port...22 is usually the safe bet


## Posts

Posts are simply Markdown files in the **posts/** directory. The name of the file will become part of the post's URL (ex: test-post.md will have a slug of /2013/04/22/test-post).

The first line is the post's title, and right under that is where you can place some key/value pairs that will be treated as variables and passed down to your template.

	Post Title
	==========
	Type: text
	Tags: sample, post
	Published: 2013-03-27 12:00:00

	The FIRST post.

	And a second paragraph for good meassure.

So in the example above, you'll have a title of: "Post Title". The template will also have access to variables: type and tags. You can practically put anything here and it will be passed down to the template.

Some variables have special meaning to Hey.coffee, and affects how it works:

- **Type:**  Hey.coffee will check for the type variable in your posts and create a variable with a value of true for use in your templates. If you have a type of *link* in your post file, your template will get a variable named *isLink*
- **Tags:** This field isn't required, but when it is it should be a comma seperated list
- **Published:** This variable will let Hey.coffee know when your story should be published, and what order to display your posts in. If this variable isn't included in your Markdown file, it won't be published to the front page of your site. It must also be in this format: 2013-03-27 12:00:00

## Pages

Pages are pretty much the same deal as posts. You place them in the **pages/** directory, and the same rules regarding variables apply with the exception of *published*. The published variable is not required.

## To Do

- Generate Makefile
- Write tests

## The License (MIT)
Copyright (c) 2013 TJ Eastmond

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.