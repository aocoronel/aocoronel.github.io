#!/usr/bin/env python3
from bs4 import BeautifulSoup
from xml.etree import ElementTree as ET
from pathlib import Path
from datetime import datetime
from var import index_file, link, sitemap_output_file

WEBSITE_DIR = Path(index_file).resolve().parent
now = datetime.now().strftime('%Y-%m-%d')

EXCLUDE = {
    '404.html',
    'custom-index.html',
}

with open(index_file, 'r', encoding='utf-8') as file:
    soup = BeautifulSoup(file.read(), 'html.parser')

static_pages = []
for entry in sorted(WEBSITE_DIR.iterdir()):
    name = entry.name
    if name in EXCLUDE:
        continue
    if name == 'index.html':
        static_pages.append({'loc': link, 'lastmod': now})
    elif entry.is_dir():
        static_pages.append({'loc': f'{link}/{name}/', 'lastmod': now})
    elif name.endswith('.html'):
        static_pages.append({'loc': f'{link}/{name}', 'lastmod': now})

posts = []
posts_section = soup.find('h1', {'id': 'posts'})
if posts_section:
    next_node = posts_section.find_next_sibling()
    while next_node and next_node.name not in ['hr', 'h1']:
        if next_node.name == 'p':
            link_tag = next_node.find('a')
            if link_tag:
                date_text = next_node.get_text(strip=True).split('•')[0].strip()
                try:
                    lastmod = datetime.strptime(date_text, '%b %d, %Y').strftime('%Y-%m-%d')
                except ValueError:
                    lastmod = now
                posts.append({
                    'loc': f'{link}/{link_tag["href"]}',
                    'lastmod': lastmod,
                })
        next_node = next_node.find_next_sibling()

urlset = ET.Element('urlset', attrib={
    'xmlns': 'http://www.sitemaps.org/schemas/sitemap/0.9'
})

for page in static_pages + posts:
    url_el = ET.SubElement(urlset, 'url')
    ET.SubElement(url_el, 'loc').text = page['loc']
    ET.SubElement(url_el, 'lastmod').text = page['lastmod']
    ET.SubElement(url_el, 'changefreq').text = 'monthly'
    ET.SubElement(url_el, 'priority').text = '0.8'

ET.indent(urlset)

Path(sitemap_output_file).parent.mkdir(parents=True, exist_ok=True)
ET.ElementTree(urlset).write(sitemap_output_file, encoding='utf-8', xml_declaration=True)
print("Sitemap generated successfully!")
