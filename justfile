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

# Make projects page
projects:
	bash build-pages _pages/projects.md

# Make all posts
posts:
  bash build-pages

# Make everything
all: posts projects about index master-index

# Make feeds
feed:
  python feedgenerator
