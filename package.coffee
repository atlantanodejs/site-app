module.exports =
    name: "atlantanodejs-site"
    description: "Admin features and demos for the Atlanta Nodejs group"
    version: "0.0.1"
    author: "Rick Thomas"
    main: "./lib/server.js"
    repository:
        type: "git"
        url: "https://github.com/atlantanodejs/site_app.git"
    directories:
        lib: "lib"
    dependencies:
        underscore: "~1.2.3"
        connect: "1.8.x"
        quip: "*"
        shred: "*"
        glob: "*"
        passport: ">= 0.0.6"
        'passport-github': ">= 0.0.0"
        'passport-meetup': ">= 0.0.0"
    devDependencies:
        buster: "*"
        icing: "*"
        'coffee-script': "*"
    engines:
        node: "0.6.x"
    licenses: [
        type: "MIT"
        url: "https://github.com/atlantanodejs/site_app/raw/master/LICENSE"
    ]


