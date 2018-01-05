# Hey-coffee Tests
# TJ Eastmond - tj.eastmond@gmail.com
# Copyright 2013

Hey = require '../'
should = require 'should'
mkdirp = require 'mkdirp'
fs = require 'fs'
exec = require('child_process').exec

blogDir = process.cwd() + '/test/blog/'

# misc functions
create_blog_folder = ->	mkdirp.sync blogDir
delete_blog_folder = (callback) -> exec "rm -rf #{blogDir}", callback
create_new_blog = ->
	do create_blog_folder
	@hey = new Hey blogDir
	do @hey.init

describe 'Hey-coffee', ->
	before -> @hey = new Hey
	it 'exists', -> @hey.should.be.an.Object
	it 'should have the methods the CLI depends on', ->
		@hey.init.should.be.type 'function'
		@hey.server.should.be.type 'function'
		@hey.publish.should.be.type 'function'
		@hey.watch.should.be.type 'function'

describe 'Creating a blog', ->
	before -> create_new_blog.call this
	after (done) -> delete_blog_folder done

	it 'should throw an error if a blog already exists', -> (=> @hey.init()).should.throw()
	it 'should create a config file', -> fs.existsSync(@hey.configFile).should.be.true
	it 'should create a posts directory', -> fs.existsSync(@hey.postPath()).should.be.true
	it 'should create a pages directory', -> fs.existsSync(@hey.pagesDir).should.be.true
	it 'should create a public directory', -> fs.existsSync(@hey.publicDir).should.be.true
	it 'should create a layouts directory', -> fs.existsSync(@hey.layoutsDir).should.be.true
	it 'should create a site directory', -> fs.existsSync(@hey.siteDir).should.be.true
	it 'should create a cache file', -> fs.existsSync(@hey.cacheFile).should.be.true
	it 'should create a template file', -> fs.existsSync(@hey.templatePath(@hey.defaultTemplateFile)).should.be.true

describe 'Building a blog', ->
	before -> create_new_blog.call this
	after (done) -> delete_blog_folder done

	it 'should not throw errors', (done) ->
		@hey.build done

	it 'should update the cache', (done) ->
		cache = JSON.parse fs.readFileSync(@hey.cacheFile).toString()
		cache.should.have.length 1
		do done

	it 'should create HTML files', (done) ->
		fs.existsSync("#{blogDir}site/index.html").should.be.true
		fs.existsSync("#{blogDir}site/2013/04/index.html").should.be.true
		fs.existsSync("#{blogDir}site/2013/04/22/first-post/index.html").should.be.true
		fs.existsSync("#{blogDir}site/tags/tests/index.html").should.be.true
		do done

describe 'Archiving a blog', ->
	before -> create_new_blog.call this
	after (done) -> delete_blog_folder done

	it 'should create the versions directory', (done) ->
		@hey.backup =>
			fs.existsSync(@hey.versionsDir).should.be.true
			do done

	it 'should create the gzip file', (done) ->
		fs.readdirSync(@hey.versionsDir).should.have.length 1
		do done
