# Hey-coffee

**These docs are very much a work in progress. As this software is still in its early stages, there will occasionally be a few things re-thought and refactored. Thanks for dealing with my bad behavior.**

Hey-coffee is a simple flatfile blog tool. Write your posts with markdown, and publish via the commandline. You place your post files in the posts directory, and anything static like CSS or JavaScript into the public/ directory. When the build command is called, these things happen:

* The site folder is cleared
* The contents of the public folder are rsync'd over to the site folder
* All posts and pages are rendered to HTML
* The index page is generated
* Archive and tag pages are generated

Simple! This workflow is great for me, as a developer I'm comfortable at the terminal. Hopefully you'll like it too.

### Requirements

Hey.coffee is written entirely in CoffeeScript. Requirments are few:

- Node.js
- CoffeeScript installed globally (npm install -g coffee-script)

You will need a webserver somewhere for Hey-coffee to post your generated website to. That host should allow you access to rsync.

## Installing

	> npm install -g hey-coffee

Once you have Hey.coffee installed, you can open a shell and run the following command to get info on how to use it:

	> hey --help


## Getting Started

To setup a new blog, create an empty directory and run this command:

	> hey --init

This will generate the base structure of your new blog:

- **Posts directory:** Save your markdown posts here. A sample is created by the init command
- **Pages directory:** Save your pages here
- **Public directory:** Put your static content here (CSS, Images, JavaScript)
- **hey-config.json:** Open this file and configure it. More on this to follow
- **hey-cache.json:** Hey-coffee uses this file to store your processed posts

### hey-config.json

In this file we have some basic parameters that need setting:

- **siteTitle:** The name of your blog
- **author:** Your name as it will appear in your rss feed
- **description:** Your site's description as it will appear in your rss feed
- **site:** Your site's URL. Should include 'http://' and have no trailing slash
- **postsOnHomePage:** The number of posts on your home page
- **server:** For the rsync: user@yoursite.com:/path/to/blog
- **port:** The ssh port. Usually 22

Everything except the server parameter will be passed down to your templates, so if you want to add a copyright or anything else this a good place to do it.

## Posts

Posts are markdown files in the **posts/** directory. The name of the file will become part of the post's URL (ex: test-post.md will have a slug of /2013/04/22/test-post).

The first line is the post's title, and right under that is where you can place some key/value pairs that will be treated as variables and passed down to your template.

	Post Title
	==========
	Type: text
	Tags: sample, post
	Published: 2013-03-27 12:00:00

	The FIRST post.

	And a second paragraph for good meassure.

In the example above, you'll have a title of: "Post Title". The template will also have access to variables: type and tags. You can put practically anything here and it will be passed down to the template.

### Reserved Variables

Some variables have special meaning to Hey-coffee, and affects how it works:

- **Type:**  Hey.coffee will check for the type variable in your posts and create a variable with a value of true for use in your templates. If you have a type of *link* in your post file, your template will get a variable named *isLink*
- **Tags:** This field isn't required, but when it is it should be a comma seperated list
- **Published:** This variable will let Hey-coffee know how to sort your posts. If this variable isn't included, the post won't be published to the front page. It must be in the format: 2013-03-27 23:00:00

## Pages

Pages are pretty much the same deal as posts. You place them in the **pages/** directory, and the same rules regarding variables apply with the exception of *published*. The published variable is not required. Pages also get a special _isPage_ variable passed to the template.

## To Do

- Finish docs

## The License (MIT)
Copyright (c) 2013 TJ Eastmond

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.