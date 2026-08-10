---
title: gha
description: Interact with GitHub starred repositories and manage following users
source: ./gha
---

`gha` is a simple script to interact with GitHub starred repositories and managing following users.

## Features

- Add and remove starred or following users
- Store repositories and users in local file

## Requirements

- `jq`
- `gh`

## Usage

```console
gha | GitHub API

Usage: gha [OPTION] [COMMAND] [INPUT]

Commands:
  add [-f] [user]         Follow user
  add [-s] [user/repo]    Star repo
  browse [user|user/repo] Open user or repo in browser
  del [-f] [user]         Unfollow user
  del [-s] [user/repo]    Unstar repo
  help                    Displays this message and exits
  sync                    Sync local database
```

## License

This project is available as public-domain under the CC0 License.
