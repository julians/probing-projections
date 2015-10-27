Interactive MDS Visualisation
=============================

This thing generates an MDS visualisation for you. Just paste your spreadsheet data and go.

How to set up
-------------

### What you need:

* [node.js](http://nodejs.org)
* [grunt](http://gruntjs.com)

It’s easiest to install node with [homebrew](http://brew.sh).

To install grunt (you need to have node installed): `npm install -g grunt-cli`


### Set-up instructions

1. clone git repository
2. open directory in Terminal

`grunt server` then watches the files for changes and compiles them for you. It’ll also serve them up on [localhost:9000](http://localhost:9000/).

You may need to quit and restart `grunt server` occasionally if something in `Gruntfile.js` or `package.json` changes.


### Distributing

`grunt staticbuild` builds the project with absolute paths for deployment, `grunt` builds it with relative paths if you want that for whatever reason.