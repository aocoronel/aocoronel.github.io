#!/usr/bin/env python3

from bs4 import BeautifulSoup
from xml.etree import ElementTree as ET
import datetime
import os

from var import index_file, lang, description, link, username, rss_output_file

with open(index_file, 'r', encoding='utf-8') as file:
    html_content = file.read()

soup = BeautifulSoup(html_content, 'html.parser')

rss = ET.Element('rss', attrib={'version': '2.0'})
channel = ET.SubElement(rss, 'channel')
ET.SubElement(channel, 'title').text = username
ET.SubElement(channel, 'link').text = link
ET.SubElement(channel, 'description').text = description
ET.SubElement(channel, 'language').text = lang

posts_section = soup.find('h2', {'id': 'latest-posts'})
if posts_section:
    next_node = posts_section.find_next_sibling()
    while next_node and next_node.name not in ['hr', 'h1']:
        if next_node.name == 'p':
            date_text = next_node.get_text(strip=True).split('•')[0].strip()
            if date_text == "See all posts":
               break
            link_tag = next_node.find('a')
            if link_tag and date_text:
                title = link_tag.text
                link_ = link + link_tag['href']

                try:
                    pub_date = datetime.datetime.strptime(
                            date_text, '%b %d, %Y %H:%M'
                    ).replace(tzinfo=datetime.timezone.utc)
                except ValueError as e:
                    print(f"Error parsing date {date_text}: {e}")
                    next_node = next_node.find_next_sibling()
                    continue

                item = ET.SubElement(channel, 'item')
                ET.SubElement(item, 'title').text = title
                ET.SubElement(item, 'link').text = link_
                ET.SubElement(item, 'description').text = title
                ET.SubElement(item, 'pubDate').text = pub_date.strftime(
                    '%a, %d %b %Y %H:%M -0300'
                )
        next_node = next_node.find_next_sibling()

os.makedirs(os.path.dirname(rss_output_file), exist_ok=True)

try:
    ET.ElementTree(rss).write(
        rss_output_file, encoding='utf-8', xml_declaration=True
    )
    print("RSS feed generated successfully!")
except Exception as e:
    print(f"An error occurred while writing the file: {e}")
