# Hey-Coffee!
# TJ Eastmond - tj.eastmond@gmail.com
# Copyright 2013

fs = require 'fs'
path = require 'path'
crypto = require 'crypto'
http = require 'http'
url = require 'url'
{spawn, exec} = require 'child_process'
async = require 'async'
_ = require 'underscore'
marked = require 'marked'
handlebars = require 'handlebars'
mkdirp = require 'mkdirp'
rss = require 'rss'
colors = require 'colors'

require 'date-utils'

Hey = module.exports = class
	constructor: () ->
		@cwd = process.cwd() + "/"
		@template = null
		@cacheFile = "#{@cwd}hey-cache.json"
		@configFile = "#{@cwd}hey-config.json"
		@templateFile = "#{@cwd}template.html"
		@pagesDir = "#{@cwd}pages/"
		@siteDir = "#{@cwd}site/"
		@publicDir = "#{@cwd}public/"
		@rssFile = "#{@cwd}site/rss.xml"

	init: ->
		if fs.existsSync(@configFile) and fs.existsSync(@postPath())
			console.log 'A blog is already setup here'
			return false

		mkdirp @siteDir
		mkdirp @pagesDir
		mkdirp @publicDir
		mkdirp @postPath()

		defaults = @defaults()
		fs.writeFileSync @cacheFile, '', 'utf8'
		fs.writeFileSync @templateFile, defaults.tpl, 'utf8'
		fs.writeFileSync @configFile, defaults.config, 'utf8'
		fs.writeFileSync @postPath('first-post.md'), defaults.post, 'utf8'
		yes

	server: =>
		do @loadConfig

		server = http.createServer (req, res) =>
			uri = url.parse(req.url).pathname
			filename = path.join "#{@cwd}site", uri
			fs.exists filename, (exists) ->
				if exists is false
					res.writeHead 404, 'Content-Type': 'text/plain'
					res.write '404 Not Found\n'
					res.end()
					return false

				filename += '/index.html' if fs.statSync(filename).isDirectory()

				fs.readFile filename, 'binary', (error, file) ->
					if error?
						res.writeHead 500, 'Content-Type': 'text/plain'
						res.write error + "\n"
						res.end()
						return false

					res.writeHead 200
					res.write file, 'binary'
					res.end()

		server.listen 3000
		console.log "Server running at http://localhost:3000".green
		console.log "CTRL+C to stop it".white

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

	pageFiles: ->
		readDir @pagesDir

	setType: (post) ->
		return post unless post.type
		post["is#{ucWord post.type}"] = true
		post

	postInfo: (filename, isPage) ->
		file = if isPage is true then "#{@pagesDir}#{filename}" else @postPath filename
		content = fs.readFileSync(file).toString()
		hash = md5 content
		content = content.split '\n\n'
		top = content.shift().split '\n'
		post =
			name: filename
			title: top[0]
			slug: path.basename filename, '.md'
			hash: hash
			body: @markup content.join '\n\n'
			tags: []

		for setting in top[2..]
			parts = setting.split ': '
			key = parts[0].toLowerCase()
			post[key] = if key is 'tags'
				parts[1].split(',').map((s) -> s.trim())
			else
				parts[1]

		if post.published
			date = new Date post.published
			post.prettyDate = date.toFormat @config.prettyDateFormat
			post.ymd = date.toFormat @config.ymdFormat
			post.permalink = @permalink post.published, post.slug
			post.archiveDir = post.published[0..6]
			post.canonical = @config.site + post.permalink

		if isPage is true
			post.slug += '/'
			post.type = 'page'

		@setType post

	update: (callback) ->
		do @loadConfig
		posts = @postFiles()
		@cache = []
		@cache.push @postInfo(post) for post in posts
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
			exec "rsync -vur --delete public/ site", (err, stdout, stderr) =>
				throw err if err

				writePostFile = (post, next) =>
					return next null unless _.has post, 'published'
					dir = @postDir post.published, post.slug
					mkdirp.sync dir unless fs.existsSync dir
					fs.writeFile "#{dir}/index.html", @render([post]), 'utf8'
					do next

				async.each @cache, writePostFile, (error) =>
					async.parallel [@buildArchive, @buildTags, @buildIndex, @buildPages], (error) ->
						callback?()

	buildIndex: (callback) =>
		index = @config.postsOnHomePage - 1
		posts = @cache.filter((p) -> 'published' in _.keys p)[0..index]
		fs.writeFileSync "#{@cwd}site/index.html", @render(posts), 'utf8'
		@buildRss posts
		callback?(null)

	buildRss: (posts, callback) =>
		feed = new rss
			title: @config.siteTitle
			description: @config.description
			feed_url: "#{@config.site}/rss.xml"
			site_url: @config.site
			author: @config.author

		for post in posts
			feed.item
				title: post.title
				description: post.body
				url: "#{@config.site}#{post.permalink}"
				date: post.published

		fs.writeFileSync @rssFile, feed.xml(), 'utf8'

		callback?(null)

	buildPages: (callback) =>
		for page in @pageFiles()
			data = @postInfo page, yes
			pageDir = "#{@siteDir}#{data.slug}"
			mkdirp.sync pageDir
			fs.writeFileSync "#{pageDir}index.html", @render([data]), 'utf8'

		callback?(null)

	buildTags: (callback) =>
		@tags = {}
		for post in @cache when post.tags.length > 0
			for tag in post.tags when _.has post, 'published'
				@tags[tag] = [] unless _.has @tags, tag
				@tags[tag].push post

		for tag, posts of @tags
			tagDir = "#{@siteDir}tags/#{tag}/"
			mkdirp.sync tagDir unless fs.existsSync tagDir
			fs.writeFileSync "#{tagDir}index.html", @render(posts), 'utf8'

		callback?(null)

	buildArchive: (callback) =>
		@archive = {}
		for post in @cache when 'published' in _.keys post
			@archive[post.archiveDir] = [] unless _.has @archive, post.archiveDir
			@archive[post.archiveDir].push post

		for archiveDir, posts of @archive
			archiveDir = "#{@siteDir}archives/#{archiveDir.replace('-', '/')}/"
			mkdirp.sync archiveDir unless fs.existsSync archiveDir
			fs.writeFileSync "#{archiveDir}index.html", @render(posts), 'utf8'

		callback?(null)

	watch: (callback) =>
		console.log 'Watching for changes and starting the server'.yellow
		do @server

		rebuild = (msg) => @build -> console.log "#{new Date().toFormat('HH24:MI:SS')} #{msg}".grey

		handlePostsAndPages = (ev, filename) =>
			rebuild 'Recompiling posts and pages' if filename and path.extname(filename) is '.md'

		# watch posts and pages for changes
		fs.watch @postPath(), handlePostsAndPages
		fs.watch @pagesDir, handlePostsAndPages

		fs.watchFile @templateFile, persistent: true, interval: 1000, (curr, prev) =>
			@template = null
			rebuild 'Recompiling template'

		rebuild 'Built the site'

	markup: (content) ->
		content = marked(content).trim()
		content.replace /\n/g, ""

	render: (posts) ->
		throw "Posts must be an array" unless _.isArray posts
		do @loadTemplate

		options = _.omit @config, 'server'
		options.pageTitle = @pageTitle if posts.length is 1 then posts[0].title else ''

		if posts.length is 1 and posts[0].type isnt 'page'
			options.isArticle = true
			options.opengraph = true
			options.og_title = posts[0].title
			options.og_canonical = posts[0].canonical

		html = @template _.extend options, posts: posts
		html.replace /\n|\r|\t/g, ''

	pageTitle: (postTitle) ->
		if postTitle then "#{postTitle} | #{@config.siteTitle}" else @config.siteTitle

	defaults: ->
		config = [
			'{'
			'  "siteTitle": "Hey, Coffee! Jack!",'
			'  "author": "Si",'
			'  "description": "My awesome blog, JACK!",'
			'  "site": "http://yoursite.com",'
			'  "postsOnHomePage": 20,'
			'  "server": "user@yoursite.com:/path/to/your/blog",'
			'  "port": 22,'
			'  "prettyDateFormat": "DDDD, DD MMMM YYYY",'
			'  "ymdFormat": "YYYY-MM-DD"'
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

		{ config, post, tpl }

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

ucWord = (string) ->
	string.charAt(0).toUpperCase() + string.slice 1
