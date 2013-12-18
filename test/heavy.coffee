Hey = require '../'
mkdirp = require 'mkdirp'
async = require 'async'
fs = require 'fs'
exec = require('child_process').exec
handlebars = require 'handlebars'

class HeyTest
	constructor: (@blog_dir, options) ->
		options or= {}
		@hey = null
		@number_of_posts = options.number_of_posts or 1000
		@fixtures_file = options.fixtures_file or './fixtures/posts'
		@tpl = handlebars.compile "{{title}}\n=========\nType: Text\nPublished: {{date}}\nTags: {{tags}}\n\n {{body}}"

	create_blog_folder: (callback) ->
		mkdirp.sync @blog_dir

	delete_blog_folder: (callback) ->
		exec "rm -rf #{blog_dir}", callback

	create_new_blog: (callback) =>
		@create_blog_folder()
		@hey = new Hey @blog_dir
		@hey.init()
		callback?()

	loadFixtures: =>
		@data = require @fixtures_file

	@make_post = (n, callback) ->
		title = randomItem @data.titles
		post = tpl
			title: title
			date: randomItem @data.dates
			tags: randomItem @data.tags
			body: randomItem @data.contents

		fs.writeFileSync makeFilename(title, n), post
		callback null, post

	load_test: =>
		@create_new_blog =>
			@loadFixtures()
			console.log typeof @make_post
			# async.times @number_of_posts, console.log, (error, posts) =>
			# 	@hey.build => @delete_blog_folder()

randomItem = (items) ->
	items[Math.floor(Math.random() * items.length)]

makeFilename = (title, n) ->
	"#{blogDir}/posts/"+ title.toLowerCase().replace(/\s/g, '-') + "-#{n}.md"

test = new HeyTest process.cwd() + '/blog/'
test.load_test()
