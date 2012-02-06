_ = require 'underscore'
require 'icing'
path = require 'path'
fs   = require 'fs'
path   = require 'path'
{exec} = require 'child_process'


module_path  = path.dirname fs.realpathSync __filename # Cakefile path == process.cwd()


option '-t','--tap','Run tests with tap output'
# choose config, dev or prod, choosing from config ... process.env.NODE_ENV=test
# options.verbose applied to tests

task 'version', 'version', -> 
    package = require "./package.coffee" 
    console.log package.version

task 'compile_config', 'Convert package.coffee to package.json',
    ['package.coffee', 'config/config.coffee'],
    recipe: ->
        exec "coffee -c package.coffee", (error) =>
            # compile to js first. the internal compile may not be done before import
            package = require "./package.js"
            package_json_path = path.join module_path, 'package.json'
            try
                fs.writeFileSync package_json_path, (JSON.stringify package, null, 4)
                fs.unlinkSync path.join module_path, 'package.js'
                this.finished()
            catch error
                this.failed error
        this.exec [
            "coffee -c -o config/ config/config.coffee"
            ]
    outputs: ->
        ['package.json', 'config/config.js'] # package_json_path but icing compares strings??

task 'compile_src', 'Compile from coffeescript in src to js in lib', 
    ['src/*.coffee'],
    recipe: -> 
        this.exec [
            "coffee -c -o lib/ #{this.modifiedPrereqs.join(' ')}"
            ]
    outputs: ->
        for prereq in this.filePrereqs
            prereq.replace /src\/(.*).coffee/,"lib/$1.js" # note: returns [ ] of modified prereq

task 'compile_tests', 'Compile tests from cs to js',
    ['test/config-tests.coffee', 'test/server/*.coffee', 'test/browser/*.coffee'],
    recipe: ->
        this.exec [
            "coffee -c -o test/ test/config-tests.coffee"
            "coffee -c -o test/browser/ test/browser/*.coffee"
            "coffee -c -o test/server/ test/server/*.coffee"
            ]
    outputs: (options) ->
        for prereq in this.filePrereqs
            prereq.replace /(.*).coffee/,"$1.js"

task 'compile', 'Compile config, tests, and source', 
    ['task(compile_config)', 'task(compile_tests)', 'task(compile_src)'], (options) ->
        this.finished()

task 'test_server', 'Run server tests', ['task(compile)'], (options) ->
    command = "./node_modules/buster/bin/buster test --config test/config-tests.js -e node"
    this.exec [
        command
        ]

task 'test_browser', 'Run browser tests', ['task(compile)'], (options) ->
    command = "./node_modules/buster/bin/buster test --config test/config-tests.js -e browser"
    this.exec [
        command
        ]