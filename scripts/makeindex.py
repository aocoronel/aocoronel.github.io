#!/usr/bin/env python3

import os
import re
from pathlib import Path
from typing import Tuple, List

SOURCE_DIR = "_posts"
INDEX_PATH = "index.md"
ARCHIVE_PATH = "archive.md"


def find_post_files(source_dir: str) -> List[Path]:
    pattern = re.compile(r"\d{4}-\d{2}-\d{2}-.*\.md$")
    files = []

    for root, _, filenames in os.walk(source_dir, followlinks=True):
        for filename in filenames:
            if pattern.match(filename):
                files.append(Path(root) / filename)

    return sorted(files, key=lambda p: p.name, reverse=True)


def extract_front_matter(file_path: Path) -> Tuple[str, str]:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for i, line in enumerate(f):
                if i >= 20:
                    break

                if line.startswith('title:'):
                    title = line.replace('title:', '').strip()
                elif line.startswith('date:'):
                    date = line.replace('date:', '').strip()

            return title, date
    except Exception as e:
        print(f"Warning: Could not read {file_path}: {e}")
        return "", ""


def build_link(title: str, date: str, file_path: Path, base_dir: str) -> str:
    rel_path = file_path.relative_to(base_dir)
    html_path = str(rel_path).replace('.md', '.html')
    return f"{date} • [{title}]({html_path})"


def create_header(content_type: str) -> str:
    headers = {
        'index': '''---
title: Augusto Coronel
description: I'm a tech enthusiast and programming self-taught hobbist. I build CLIs for Linux
---''',
        'archive': '''---
title: Archive
description: All posts archive
---'''
    }
    return headers.get(content_type, headers['index'])


def append_custom_index(index_path: str) -> None:
    custom_path = Path("./_pages/custom-index.txt")
    if custom_path.exists():
        with open(custom_path, 'r', encoding='utf-8') as f:
            with open(index_path, 'a', encoding='utf-8') as out:
                out.write("\n")
                out.write(f.read())


def generate_posts_content(
    source_dir: str,
    max_posts: int | None = None
) -> str:
    files = find_post_files(source_dir)

    if max_posts is not None:
        files = files[:max_posts]

    lines = []

    for file_path in files:
        title, date = extract_front_matter(file_path)
        if title and date:
            link = build_link(title, date, file_path, SOURCE_DIR)
            lines.append(link)
            lines.append("")

    return "\n".join(lines)


for path in [INDEX_PATH, ARCHIVE_PATH]:
    if os.path.exists(path):
        os.remove(path)

with open(INDEX_PATH, 'w', encoding='utf-8') as f:
    f.write(create_header('index'))
    f.write("\n\n")
    f.write("## Latest posts\n")
    f.write(generate_posts_content(SOURCE_DIR, max_posts=5))

append_custom_index(INDEX_PATH)

with open(ARCHIVE_PATH, 'w', encoding='utf-8') as f:
    f.write(create_header('archive'))
    f.write("\n\n")
    f.write("## Posts\n")
    f.write(generate_posts_content(SOURCE_DIR, max_posts=None))

os.system("python ./scripts/build-pages.py --basic index.md")
os.system("python ./scripts/build-pages.py --basic archive.md")

os.remove(INDEX_PATH)
os.remove(ARCHIVE_PATH)

print("Index and archive built successfully")
