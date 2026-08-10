import os

username = 'Augusto Coronel'
link = 'https://aocoronel.codeberg.page'
description = "I’m a tech enthusiast and programming self-taught hobbist. I build CLIs for Linux."
lang = 'en-us'

script_dir = os.path.dirname(os.path.abspath(__file__))
index_file = os.path.normpath(os.path.join(script_dir, '../_website/index.html'))
sitemap_output_file = os.path.normpath(os.path.join(script_dir, '../_website/sitemap.xml'))
rss_output_file = os.path.normpath(os.path.join(script_dir, '../_website/feed.xml'))
