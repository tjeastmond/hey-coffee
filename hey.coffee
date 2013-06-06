# Hey-Coffee!
# TJ Eastmond - tj.eastmond@gmail.com
# Copyright 2013

fs = require 'fs'
path = require 'path'
async = require 'async'
crypto = require 'crypto'
_ = require 'underscore'
marked = require 'marked'
handlebars = require 'handlebars'
mkdirp = require 'mkdirp'
http = require 'http'
url = require 'url'
{spawn} = require 'child_process'

require 'date-utils'

Hey = module.exports = class
	constructor: () ->
		@cwd = process.cwd() + "/"
		@template = null
		@cacheFile = "#{@cwd}hey-cache.json"
		@configFile = "#{@cwd}hey-config.json"
		@templateFile = "#{@cwd}template.html"
		@siteDir = "#{@cwd}site/"

	init: ->
		if fs.existsSync(@configFile) and fs.existsSync(@postPath())
			console.log 'A blog is already setup here'
			return false

		mkdirp @siteDir
		mkdirp @postPath()
		defaults = @defaults()
		fs.writeFileSync @cacheFile, '', 'utf8'
		fs.writeFileSync @templateFile, defaults.tpl, 'utf8'
		fs.writeFileSync @configFile, defaults.config, 'utf8'
		fs.writeFileSync @postPath('first-post.md'), defaults.post, 'utf8'

		yes

	server: ->
		do @loadConfig
		server = http.createServer (req, res) =>
			uri = url.parse(req.url).pathname
			filename = path.join "#{@cwd}site", uri
			return false if uri is '/favicon.ico'
			fs.exists filename, (exists) ->
				if not exists
					res.writeHead 404, 'Content-Type': 'text/plain'
					res.write '404 Not Found\n'
					res.end()
					false

				filename += '/index.html' if fs.statSync(filename).isDirectory()

				fs.readFile filename, 'binary', (error, file) ->
					if error?
						res.writeHead 500, 'Content-Type': 'text/plain'
						res.write error + "\n"
						res.end()
						false

					res.writeHead 200
					res.write file, 'binary'
					res.end()

		server.listen 3000
		console.log "Server running at http://localhost:3000"
		console.log "CTRL+C to stop it"

	publish: ->
		do @loadConfig
		@rsync @siteDir, @config.server

	rsync: (from, to, callback) ->
		port = "ssh -p #{@config.port or 22}"
		child = spawn "rsync", ['-vurz', '--delete', '-e', port, from, to]
		child.stdout.on 'data', (out) -> console.log out.toString()
		child.stderr.on 'data', (err) -> console.error err.toString()
		child.on 'exit', callback if callback

	loadConfig: ->
		@config = readJSON @configFile
		yes

	loadCache: ->
		@cache = readJSON(@cacheFile) or []
		yes

	loadTemplate: ->
		return true if @template?
		@template = handlebars.compile fs.readFileSync(@templateFile).toString()
		yes

	postPath: (filename) ->
		"#{@cwd}posts/#{filename or ''}"

	postFiles: ->
		readDir @postPath()

	postInfo: (filename, includeBody) ->
		content = fs.readFileSync(@postPath(filename)).toString()
		hash = md5 content
		content = content.split '\n\n'
		top = content.shift().split '\n'

		post =
			name: filename
			title: top[0]
			slug: path.basename filename, '.md'
			hash: hash
			body: @markup content.join '\n\n'

		for setting in top[2..]
			parts = setting.split ': '
			key = parts[0].toLowerCase()
			post[key] = if key is 'tags'
				parts[1].split(',').map((s) -> s.trim())
			else
				parts[1]

		post.permalink = @permalink post.published, post.slug if post.published

		post

	update: (callback) ->
		do @loadConfig
		do @loadCache
		cacheFiles = _.pluck @cache, 'name'
		posts = @postFiles()

		for post, i in @cache
			current = @postInfo post.name
			@cache[i] = current if post.hash isnt current.hash

		@cache.push @postInfo(post) for post in posts when post not in cacheFiles
		@cache = _.sortBy @cache, (post) -> (if post.published then new Date(post.published) else 0) * -1

		fs.writeFileSync @cacheFile, JSON.stringify @cache

		callback?()

		yes

	postDir: (pubDate, slug) ->
		date = new Date pubDate
		"#{@cwd}site/#{date.toFormat 'YYYY/MM/DD'}/#{slug}"

	permalink: (pubDate, slug) ->
		date = new Date pubDate
		"/#{date.toFormat 'YYYY/MM/DD'}/#{slug}/"


	build: (callback) ->
		@update =>
			for post in @cache when 'published' in _.keys post
				path = @postDir post.published, post.slug
				mkdirp.sync path unless fs.existsSync path
				fs.writeFileSync "#{path}/index.html", @render([post]), 'utf8'
				yes

			@buildIndex callback?

		yes

	buildIndex: (callback) ->
		index = @config.postsOnHomePage - 1
		posts = @cache[0..index].filter (p) -> 'published' in _.keys p
		fs.writeFileSync "#{@cwd}site/index.html", @render(posts), 'utf8'
		callback?()
		yes

	markup: (content) ->
		content = marked(content).trim()
		content.replace /\n/g, ""

	render: (posts) ->
		throw "Posts must be an array" unless _.isArray posts
		do @loadTemplate
		options = _.omit @config, 'server'
		options.siteTitle = @pageTitle if posts.length is 1 then posts[0].title else ''
		@template _.extend options, posts: posts

	pageTitle: (postTitle) ->
		if postTitle then "#{postTitle} | #{@config.siteTitle}" else @config.siteTitle

	defaults: ->
		config = [
			'{'
			'  "siteTitle": "Hey, Coffee! Jack!",'
			'  "author": "Si Rob",'
			'  "description": "My awesome blog, JACK!",'
			'  "site": "yoursite.com",'
			'  "postsOnHomePage": 20,'
			'  "server": "user@yoursite.com:/path/to/your/blog",'
			'  "port": 22'
			'}'
		].join '\n'

		post = [
			'First Post'
			'=========='
			'Published: 2012-03-27 12:00:00'
			'Type: text'
			''
			'This is a test post.'
			''
			'This is a second paragraph.'
		].join '\n'

		tpl = [
			'<!DOCTYPE html>'
			'<html>'
			'	<head>'
			'		<title>{{siteTitle}}</title>'
			'	</head>'
			'	<body>'
			'		{{#each posts}}'
			'		<div>'
			'			<h2><a href="{{permalink}}">{{title}}</a></h2>'
			'			{{{body}}}'
			'		</div>'
			'		{{/each}}'
			'	</body>'
			'</html>'
		].join '\n'

		{config, post, tpl}

# utility functions
readJSON = (file) ->
	throw "JSON file doesn't exist: #{file}" unless fs.existsSync file
	fileContents = fs.readFileSync(file).toString()
	if fileContents then JSON.parse(fileContents) else []

readDir = (dir) ->
	throw "Directory doesn't exist: #{dir}" unless fs.existsSync dir
	files = fs.readdirSync(dir).filter (f) -> f.charAt(0) isnt '.'
	files or []

md5 = (string) ->
	crypto.createHash('md5').update(string).digest('hex')

