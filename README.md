This branch contains the tools to build my personal blog.

Building the blog requires `make`, `python`, `python-beautifulsoup4`, `pandoc`.

```bash
git clone https://github.com/aocoronel/blog blog
cp --recursive blog build-pages
ln -s blog/_pages build-pages/
ln -s blog/_posts build-pages/
ln -s blog/_code build-pages/
cd build-pages
git checkout build-pages
make all
```

## License

This repository is licensed under the MIT license.
