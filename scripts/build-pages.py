#!/usr/bin/env python3

import argparse
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

WEBSITE_DIR = Path("_website")
SOURCE_DIR = Path("_posts")
STYLE_DIR = Path("_style")
PAGES_DIR = Path("_pages")
TEMPLATES_DIR = Path("./_templates")

def eprint(msg):
    print(f"error: {msg}", file=sys.stderr)


def relpath(target: str, start: str) -> str:
    return os.path.relpath(target, start).replace("\\", "/")


def get_title(md_file: Path) -> str:
    for line in md_file.read_text(encoding="utf-8").splitlines()[:20]:
        m = re.match(r"title:\s*(.+)", line)
        if m:
            return m.group(1).strip()
    return ""


def get_updated_date(md_file: Path) -> str:
    import datetime
    ts = md_file.stat().st_mtime
    return datetime.datetime.fromtimestamp(ts).strftime("%b %d, %Y")


def get_source_code(md_file: Path) -> str:
    for line in md_file.read_text(encoding="utf-8").splitlines()[:20]:
        m = re.match(r"source:\s*(.+)", line)
        if m:
            return m.group(1).strip()
    return ""


def get_reading_time(md_file: Path) -> str:
    text = md_file.read_text(encoding="utf-8")
    words = len(text.split())
    minutes = max(1, words // 200)
    return f"{minutes} min read"


def find_prev_next(md_file: Path):
    name = md_file.name
    date_match = re.match(r"(\d{4}-\d{2}-\d{2})-(.+)", name)
    if not date_match:
        return "", "None", "", "None"

    sub_dir = md_file.parent.name
    search_dir = SOURCE_DIR / sub_dir

    files = sorted(
        f for f in search_dir.iterdir()
        if f.is_file() and re.match(r"\d{4}-\d{2}-\d{2}-.*\.md$", f.name)
    )

    try:
        idx = files.index(md_file)
    except ValueError:
        eprint(f"{md_file} not found in {search_dir}")
        return "", "None", "", "None"

    if idx > 0:
        prev_path = files[idx - 1]
        prev_file = f"{sub_dir}/{prev_path.stem}"
        prev_title = get_title(prev_path)
    else:
        prev_file, prev_title = "", "None"

    if idx < len(files) - 1:
        next_path = files[idx + 1]
        next_file = f"{sub_dir}/{next_path.stem}"
        next_title = get_title(next_path)
    else:
        next_file, next_title = "", "None"

    return prev_file, prev_title, next_file, next_title


def run_pandoc(md_file, html_file, template, stylesheet_path,
               metadata=None, variables=None):
    cmd = [
        "pandoc", str(md_file),
        "--mathml",
        "--from=markdown",
        "--to=html",
        "--template", str(template),
        "--columns=10000",
        "--number-sections",
        "--css", stylesheet_path,
        "--toc", "--toc-depth=5",
        "--metadata", "author=Augusto Coronel",
        "--output", str(html_file),
    ]

    if variables:
        for key, val in variables.items():
            cmd.extend([f"--variable={key}:{val}"])

    if metadata:
        for key, val in metadata.items():
            cmd.extend(["--metadata", f"{key}={val}"])

    subprocess.run(cmd, check=True)

    content = html_file.read_text(encoding="utf-8")
    content = re.sub(r'^(  )(<span id="cb)', r'\2', content, flags=re.MULTILINE)
    html_file.write_text(content, encoding="utf-8")

    print(f"Converted {md_file} -> {html_file}")


def build_code(md_file: Path):
    code_dir = md_file.parent
    code_root = Path("_code")

    if code_root not in code_dir.parents:
        eprint(f"{code_dir} is not under _code")
        return

    rel = code_dir.relative_to(code_root)
    rel_str = str(rel)

    out_dir = WEBSITE_DIR / rel
    out_dir.mkdir(parents=True, exist_ok=True)

    readme = code_dir / "README.md"
    if not readme.exists():
        eprint(f"{readme} not found")
        return

    depth_parts = rel_str.split('/') if rel_str != '.' else []
    dir_depth = '../' * len(depth_parts) if depth_parts else '.'
    css_prefix = f"{dir_depth}" if dir_depth != '.' else ''

    html_file = out_dir / "index.html"
    stylesheet = f"{css_prefix}posts.css" if css_prefix else "about.css"
    template = TEMPLATES_DIR / "template-code.html"

    filepath = f"{rel_str}/index.html" if rel_str != "." else "index.html"

    variables = {
        "document_path": filepath,
        "reading_time": get_reading_time(readme),
        "source_code": get_source_code(md_file),
        "rel_path": f"{css_prefix}/" if css_prefix else "./",
    }

    run_pandoc(readme, html_file, template, stylesheet, variables=variables)

    for item in code_dir.iterdir():
        if item.is_file() and item.name != "README.md":
            shutil.copy2(item, out_dir / item.name)


def build_basic(md_file: Path):
    stem = md_file.stem
    rel = md_file.relative_to(SOURCE_DIR) if SOURCE_DIR in md_file.parents else Path(stem)
    rel_dir = rel.parent
    out_dir = WEBSITE_DIR / rel_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    html_file = out_dir / f"{stem}.html"
    dir_depth = relpath(".", str(rel_dir)) if str(rel_dir) != "." else "."

    if stem == "index":
        stylesheet = f"{dir_depth}/index.css"
        template = TEMPLATES_DIR / "template-index.html"
    else:
        stylesheet = f"{dir_depth}/about.css"
        template = TEMPLATES_DIR / "template-about.html"

    filepath = f"{rel_dir}/{stem}.html" if str(rel_dir) != "." else f"{stem}.html"

    variables = {
        "document_path": filepath,
        "reading_time": get_reading_time(md_file),
        "rel_path": f"{dir_depth}/",
    }

    run_pandoc(md_file, html_file, template, stylesheet, variables=variables)


def build_post(md_file: Path):
    stem = md_file.stem
    rel = md_file.relative_to(SOURCE_DIR) if SOURCE_DIR in md_file.parents else Path(stem)
    rel_dir = rel.parent
    out_dir = WEBSITE_DIR / rel_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    html_file = out_dir / f"{stem}.html"

    depth_parts = str(rel_dir).split('/') if str(rel_dir) != '.' else []
    dir_depth = '../' * len(depth_parts) if depth_parts else '.'

    stylesheet = f"{dir_depth}posts.css"
    template = TEMPLATES_DIR / "template-posts.html"

    prev_file, prev_title, next_file, next_title = find_prev_next(md_file)

    filepath = f"{rel_dir}/{stem}.html" if str(rel_dir) != "." else f"{stem}.html"

    variables = {
        "document_path": filepath,
        "reading_time": get_reading_time(md_file),
        "rel_path": f"{dir_depth}",
        "prev_post": prev_file,
        "next_post": next_file,
        "prev_title": prev_title,
        "next_title": next_title,
    }

    run_pandoc(md_file, html_file, template, stylesheet, variables=variables)


def add_css():
    css_files = [
        "style", "index", "variables", "further-read", "default",
        "code", "sidebar", "toc", "posts", "about", "dark-theme", "light-theme",
    ]

    for css in css_files:
        src = STYLE_DIR / f"{css}.css"
        if not src.exists():
            continue
        content = src.read_text(encoding="utf-8")
        content = re.sub(r'/.*?$', '', content, flags=re.MULTILINE)
        content = re.sub(r'^\s*\n', '', content, flags=re.MULTILINE)
        content = re.sub(r'\n+', '', content)
        (WEBSITE_DIR / f"{css}.css").write_text(content, encoding="utf-8")

    for asset in (".htaccess", "404.html", "LICENSE", "robots.txt"):
        src = PAGES_DIR / asset
        if src.exists():
            shutil.copy2(src, WEBSITE_DIR / asset)

    media = SOURCE_DIR / "media"
    if media.exists():
        shutil.copytree(media, WEBSITE_DIR / "media", dirs_exist_ok=True)

    print("CSS and assets copied.")


parser = argparse.ArgumentParser(description="Markdown to HTML site generator")
group = parser.add_mutually_exclusive_group()
group.add_argument("--basic", metavar="FILE", help="Convert a single markdown file")
group.add_argument("--code", metavar="FILE", help="Convert a single markdown file for code")
group.add_argument("--post", metavar="FILE", help="Convert a blog post with prev/next navigation")
parser.add_argument("-c", "--css", action="store_true", help="Process CSS and copy assets only")
args = parser.parse_args()

WEBSITE_DIR.mkdir(exist_ok=True)

if args.css:
    add_css()
    sys.exit(0)

if args.basic:
    md_file = Path(args.basic)
    if not md_file.exists():
        eprint(f"file not found: {md_file}")
        sys.exit(1)
    build_basic(md_file)
    sys.exit(0)

if args.code:
    md_file = Path(args.code)
    if not md_file.exists():
        eprint(f"file not found: {md_file}")
        sys.exit(1)
    build_code(md_file)
    sys.exit(0)

if args.post:
    md_file = Path(args.post)
    if not md_file.exists():
        eprint(f"file not found: {md_file}")
        sys.exit(1)
    build_post(md_file)
    sys.exit(0)
