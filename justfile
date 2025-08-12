# List recipes (default)
list:
  just --list

# Make index page
index:
	bash makeindex

# Make master index
master-index:
	bash makeindex -m

# Make about page
about:
	bash build-pages "_pages/about.md"

# Make all posts
posts:
  bash build-pages

# Make everything
all: posts about index master-index

# Make feeds
feed:
  python feedgenerator
