#!/usr/bin/env python3

# Changelog:
#
# All notable changes to this project will be documented in this file.
#
# The format is based on Keep a Changelog, some adaptation apply: https://keepachangelog.com/en/1.1.0/
# This project also adheres to Semantic Versioning: https://semver.org/spec/v2.0.0.html
#
# [0.1.0] 2026-08-09
# 	Initial release

import json
import os
import sys
import argparse
import webbrowser
from urllib.parse import quote_plus
from urllib.parse import urljoin

def open_in_browser(url):
    webbrowser.open(url)


def errorf(msg):
    print(f"error: {msg}")


def read_bang(file_path):
    if not os.path.isfile(file_path):
        errorf(f"file not found: {file_path}")
        sys.exit(1)

    with open(file_path, 'r', encoding='utf-8') as f:
        try:
            bangs = json.load(f)
        except json.JSONDecodeError as e:
            errorf(f"failed to parse JSON: {e}")
            sys.exit(1)

    if not isinstance(bangs, list):
        errorf("expected a JSON array of bangs")
        sys.exit(1)

    return bangs


def get_input(retry: bool):
    while True:
        s = input()
        if s == "":
            if retry:
                print("Nothing was provided, try again")
                continue
            else:
                return None
        return s


def add_bang(config):
    path = config

    if not os.path.isfile(path):
        path = "bangs.json"

    print("Enter title:")
    title = get_input(retry=True)
    print("Enter domain (e.g. example.com):")
    domain = get_input(retry=True).strip()
    print("Enter shortcode (e.g. e):")
    shortcode = get_input(retry=True)
    print("Enter link (e.g. ?query={{{s}}}):")
    link = get_input(retry=True).strip()
    print("Enter category (optional):")
    category = get_input(retry=False)
    print("Enter sub-category (optional):")
    subcategory = get_input(retry=False)

    if not domain.startswith(("http://", "https://")):
        domain = "https://" + domain

    full_link = urljoin(domain.rstrip("/") + "/", link.lstrip("/"))

    entry = {
        "t": title,
        "d": domain,
        "s": shortcode,
        "l": full_link,
        "c": category,
        "sc": subcategory,
    }

    data = []

    if os.path.isfile(path):
        with open(path, "r", encoding="utf-8") as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError:
                data = []

    if not isinstance(data, list):
        raise ValueError("Expected JSON file to contain a list (array) to append to.")

    data.append(entry)

    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def search_bang(bangs, target, query, browser=False):
    for bang in bangs:
        if isinstance(bang, dict) and bang.get('t') == target:
            if 'u' in bang:
                url_template = bang['u']
                encoded_query = quote_plus(query)
                url = url_template.replace("{{{s}}}", encoded_query)
                if browser:
                    open_in_browser(url)
                return url
    errorf(f'no bang found with t = "{target}"')
    return ""

def print_json_field(key, value, indent=2):
    pad = ' ' * indent
    if isinstance(value, dict):
        print(f"{pad}{key}:")
        for k, v in value.items():
            print_json_field(k, v, indent + 2)
    elif isinstance(value, list):
        print(f"{pad}{key}: [")
        for item in value:
            if isinstance(item, (dict, list)):
                print_json_field("", item, indent + 2)
            else:
                print(f"{' ' * (indent + 2)}- {item}")
        print(f"{pad}]")
    else:
        print(f"{pad}{key}: {value}")

def list_bangs(bangs):
    for bang in bangs:
        if isinstance(bang, dict) and 's' in bang and 't' in bang:
            print(f"{bang['s']}: {bang['t']}")

def inspect_bangs(bangs):
    for bang in bangs:
        if isinstance(bang, dict):
            for key, value in bang.items():
                print_json_field(key, value)
            print("")

def find_bang(bangs, request_bang, search_key="s", inline=False):
    for bang in bangs:
        if isinstance(bang, dict) and search_key in bang:
            value = str(bang[search_key])
            if request_bang.lower() in value.lower():
                if inline:
                    print(f"{bang.get('s', 'N/A')}|{bang.get('d', 'N/A')}|{bang.get('t', 'N/A')}|{bang.get('c', 'N/A')}|{bang.get('sc', 'N/A')}|{bang.get('u', 'N/A')}")
                else:
                    print(f"Title: {bang.get('s', 'N/A')}")
                    print(f"Domain: {bang.get('d', 'N/A')}")
                    print(f"Shortcode: {bang.get('t', 'N/A')}")
                    print(f"Link: {bang.get('u', 'N/A')}")
                    print(f"Category: {bang.get('c', 'N/A')}")
                    print(f"Sub-category: {bang.get('sc', 'N/A')}\n")

def main():
    parser = argparse.ArgumentParser(
        description="",
        usage="""
  sear.py [OPTION] <COMMAND> [ARGS]

commands:
  add              Add a bang
  find [BANG_NAME] Find a bang with a specified name
  inspect          Output json file
  list             Lists all bangs"""
    )

    parser.add_argument("args", nargs="*", help="Command or bang search")
    parser.add_argument("-c", "--config", default="bangs.json", help="Path to bangs JSON file")
    parser.add_argument("-b", "--browser", action="store_true", help="Open URL in browser")
    parser.add_argument("-f", "--findkey", default="s", help="Key to search for in 'find' (e.g., s, t, u)")
    parser.add_argument("-l", "--inline", action="store_true", help="Find results are inline")
    parser.add_argument("-v", "--version", action="store_true", help="Print version")

    args = parser.parse_args()

    if args.version:
        print("0.1.0")
        sys.exit(0)

    if not args.args:
        parser.print_help()
        sys.exit(1)

    command = args.args[0]

    if command == "list":
        bangs = read_bang(args.config)
        list_bangs(bangs)
    elif command == "inspect":
        bangs = read_bang(args.config)
        inspect_bangs(bangs)
    elif command == "add":
        add_bang(args.config)
    elif command == "find":
        if len(args.args) < 2:
            errorf("missing bang name for 'find'")
            sys.exit(1)
        query = " ".join(args.args[1:])

        bangs = read_bang(args.config)

        try:
            find_bang(bangs, query, args.findkey, args.inline)
        except KeyError:
            errorf("your bang file has missing JSON keys")
    else:
        if args.config:
            bangs = read_bang(args.config)

        bang = command
        query_parts = args.args[1:]
        if not query_parts:
            errorf("no search query provided")
            sys.exit(1)
        query = " ".join(query_parts)
        url = search_bang(bangs, bang, query, args.browser)
        if url and not args.browser:
            print(url)

main()
