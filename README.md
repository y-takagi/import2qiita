# ImportMd

## About

`import_md.rb` is a program to import markdown files to qiita.

## How to use

```
client = ImportMd.new(access_token: 'access_token', host: 'host')
client.run('/path/to/file.md', [tags])
client.run('/path/to/directory')
```

If you pass directory path to run method, it will import all files under the directory. Also with no tag names, directory name are automatically selected to tag names. In that case, directory name is should like `tag1.tag2.tag3/`.
