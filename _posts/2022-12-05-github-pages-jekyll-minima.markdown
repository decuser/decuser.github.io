---
layout:	post
title:	Creating a github pages jekyll minima themed site with pagination
categories:	github-pages jekyll minima
---

A note about creating a github pages jekyll minima themed blog site and about adding pagination after the fact. This note captures what I learned when I created this blog.

<!--more-->

## Prerequisites

* ruby - I use rbenv [https://github.com/rbenv](https://github.com/rbenv) with the ruby-build plugin [https://github.com/rbenv/ruby-build](https://github.com/rbenv/ruby-build)
* github account - [https://github.com](https://github.com/)
* git - It is available for download [https://git-scm.com/downloads](https://git-scm.com/downloads) but, I use macports to install [https://www.macports.org/install.php](https://www.macports.org/install.php)
* markdown editor - I use macdown [https://macdown.uranusjr.com](https://macdown.uranusjr.com/)
* text editor - bbedit on mac [https://www.barebones.com/products/bbedit/download.html](https://www.barebones.com/products/bbedit/download.html)

## First Steps

First things first. To get started we will:

1. Create a github repository
2. Clone the repo
3. Create a branch to track with our blog
4. Commit the repo
5. Turn on github-pages for the repo
6. Create a jekyll site
7. Make some changes
8. Check in the changes and push to github
9. Test the live blog


### 1. Create a github repository
Log into your github account and click the New button to create new repository. Name it whatever works and click Create Repository. Clone the repo as you usually do.

I named my repo "nifty".


### 2. Clone the repo

```
cd sandboxes-git
git clone git@github.com:decuser/nifty.git
```

The first issue was that I hadn't added my ssh key, so I dutifully uploaded my public key id_rsa.pub and tried again.

The second issue was `warning: You appear to have cloned an empty repository.`, but that's not really an issue. I plowed on.

### 3. Create a branch to track with our blog

```
cd nifty
git checkout --orphan gh-pages
cat <<EOF >readme.txt
A repo to test jekyll and pagination.
EOF
```

### 4. Commit the repo

```
git add .
git commit -m "first commit"
git push
```

Git complains:

```
fatal: The current branch gh-pages has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin gh-pages
```

The solution is:

`git push --set-upstream origin gh-pages`

### 5. Confirm github-pages is enabled for the repo
Pull up the repo in github and click on Settings. Select Pages from the left-nav. Your pages should be deployed and a `Your site is live at https://decuser.github.io/nifty/` message should be showing.

Although it's published, if you navigate to the site, you will be greeted with a 404 error. This is to be expected, we don't have any content yet.

### 6. Create a jekyll site

#### Install bundler

```
gem install bundler
Fetching bundler-2.3.26.gem
Successfully installed bundler-2.3.26
Parsing documentation for bundler-2.3.26
Installing ri documentation for bundler-2.3.26
Done installing documentation for bundler after 0 seconds
1 gem installed
```

#### Initialize bundler

```
bundle init
Writing new Gemfile to /Volumes/Tiempo/_workarea/syms/sandboxes-git/nifty/Gemfile
```

#### Add jekyll and webrick

```
bundle add jekyll webrick
Fetching gem metadata from https://rubygems.org/............
Resolving dependencies...
Fetching gem metadata from https://rubygems.org/...........
Resolving dependencies...
Using public_suffix 5.0.0
...
```

#### Add jekyll scaffolding

```
bundle exec jekyll new --force --skip-bundle .
New jekyll site installed in /Volumes/Tiempo/_workarea/syms/sandboxes-git/nifty. 
Bundle install skipped. 
tree
.
├── 404.html
├── Gemfile
├── Gemfile.lock
├── _config.yml
├── _posts
│   └── 2022-12-05-welcome-to-jekyll.markdown
├── about.markdown
├── index.markdown
└── readme.txt

1 directory, 8 files
```

Yay, we have some content, boiler plate, though it is.

#### Serve the site locally

`bundle exec jekyll serve`

Sheesh... 

```
Could not find gem 'minima (~> 2.5)' in locally installed gems.
Run `bundle install` to install missing gems.
```

```
bundle install
Fetching gem metadata from https://rubygems.org/...........
Resolving dependencies...
Using public_suffix 5.0.0
...
Bundle complete! 7 Gemfile dependencies, 32 gems now installed.
Use `bundle info [gemname]` to see where a bundled gem is installed.

bundle exec jekyll serve
```

Another sheesh - apparently jekyll uses the same port as NoMachine.

```
------------------------------------------------
Jekyll 4.3.1   Please append `--trace` to the `serve` command 
for any additional information or backtrace. 
------------------------------------------------
/Users/wsenn/.rbenv/versions/3.1.2/lib/ruby/3.1.0/socket.rb:201:in `bind': Address already in use - bind(2) for 127.0.0.1:4000 (Errno::EADDRINUSE)
```

Either shutdown the conflict or...

`bundle exec jekyll serve -P anotherport`

I just shutdown my conflict (tried both, and both worked).

browse to `http://localhost:4000`

### 7. Make some changes

Let's create a couple of handfuls of posts so we can see what that looks like.

```
cd _posts
cp 2022-12-05-welcome-to-jekyll.markdown 2022-11-25-01.markdown
cp 2022-12-05-welcome-to-jekyll.markdown 2022-11-26-02.markdown
cp 2022-12-05-welcome-to-jekyll.markdown 2022-11-27-03.markdown
cp 2022-12-05-welcome-to-jekyll.markdown 2022-11-28-04.markdown
cp 2022-12-05-welcome-to-jekyll.markdown 2022-11-29-05.markdown
cp 2022-12-05-welcome-to-jekyll.markdown 2022-11-30-06.markdown
cp 2022-12-05-welcome-to-jekyll.markdown 2022-12-01-07.markdown
cp 2022-12-05-welcome-to-jekyll.markdown 2022-12-02-08.markdown
cp 2022-12-05-welcome-to-jekyll.markdown 2022-12-03-09.markdown
cp 2022-12-05-welcome-to-jekyll.markdown 2022-12-04-10.markdown
cp 2022-12-05-welcome-to-jekyll.markdown 2022-12-05-11.markdown
cp 2022-12-05-welcome-to-jekyll.markdown 2022-12-05-12.markdown
cd ..
```

#### Test locally

browse to `http://localhost:4000`

Hmmm... not much to see here. Just a list of posts...

#### Turn on excerpts

```
vi _config.yml
add
show_excerpts: true
excerpt_separator: <!--more-->
```

The more separator will come in handy down the road, but basically anything appearing before the more separator will be included in the excerpt.

Restart jekyll `CTRL-C` to stop it and `bundle exec jekyll serve` to get it going again.

Much better... a lot of repetition, but that's what fixing pagination is for... and judicious use of the more tag.

### 8. Check in the changes and push to github

```
git add .
git commit -m "created some fake posts and turned on excerpts"
git push
```

### 9. Test the live blog

browse to the url that was given in the Pages settings of the repo. In my case:

`https://decuser.github.io/nifty/`

It will take a moment for your changes to get published. To see the publishing happening, head over to the actions tab of your repo. When it goes green the site should be ready and available and match what you have been seeing locally. 

Next up is adding pagination - who needs a never ending stream of posts anyway?

##  Adding pagination

After the blog is up and running, add pagination (sure, we should have though of it sooner, but this is real life :). In order to add pagination, after the fact, we will:

1. Clone the minima repo
2. Copy needed folders and files from the minima clone into our repo
3. Edit the Gemfile
4. Edit _config.yml
5. Covert our index.markdown file to index.html
6. Test locally
7. Commit local changes
8. Push changes to github
9. Test live


### 1. Clone the minima repo

```
cd sandboxes-git
git clone https://github.com/jekyll/minima.git
Cloning into 'minima'...
remote: Enumerating objects
...
```

### 2. Copy needed folders and files from the minima clone into our repo

The folders and files we will grab from the minima repo are:

* _includes - new to our repo
* _layouts - new to our repo
* _sass - new to our repo
* assets - new to our repo
* _config.yml - we'll back ours up

```
cd ~/sandboxes-git/nifty
cp -R ../minima/_includes .
cp -R ../minima/_layouts .
cp -R ../minima/_sass .
cp -R ../minima/assets .
cp _config.yml _config.yml-prev
cp ../minima/_config.yml .
```

Comparing the old and new _config.yml yields very little meaningful differences. The new file has some social media and seo support, but we will just redo our changes to the previous version and move on.

### 3. Edit Gemfile
add jekyll-paginate to jekyll plugins section

```
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
  gem "jekyll-paginate"
end
```

### 4. Edit _config.yml

add jekyll-paginate to the plugins section:
add excerpts properties
add paginate property

```
vi _config.yml
...
plugins:
 - jekyll-feed
 - jekyll-seo-tag
 - jekyll-paginate
...
show_excerpts: true
excerpt_separator: <!--more-->
paginate: 3
...
```

restart the jekyll server and see where we are at...

```
bundle exec jekyll serve

The following destination is shared by multiple files.
The written file may end up with unexpected contents.
/Volumes/Tiempo/_workarea/syms/sandboxes-git/nifty/_site/assets/minima-social-icons.svg
- assets/minima-social-icons.html
- /Users/wsenn/.rbenv/versions/3.1.2/lib/ruby/gems/3.1.0/gems/minima-2.5.1/assets/minima-social-icons.svg
```

This issue isn't a problem in the current context, so just ignore it.

```
Pagination: Pagination is enabled, but I couldn't find an index.html page to use as the pagination template. Skipping pagination.
Conflict: The following destination is shared by multiple files.
The written file may end up with unexpected contents.
```

This, on the other hand, is a problem, but let's take a look anyway.

browse to `http://localhost:4000`

Sure enough, it's wonky.

### 5. Covert our index.markdown file to index.html

In order for pagination to work, the index.markdown file has to be converted into an index.html file.

`mv index.markdown index.html`


### 6. Test locally

fire up the server again and ignore the shared files issue.

`bundle exec jekyll serve`

browse to `http://localhost:4000`

3 to a page, right on!

### 7. Commit local changes

```
git add .
git commit -m "added pagination"
```

### 8. Push changes to github

`git push`

watch progress over in Actions

### 9. Test live

browse to `https://decuser.github.io/nifty`

3 to a page? Success.

## Wrapping up

Celebrate or troubleshoot!

*post added 2022-12-05 17:38:00 -0600*
