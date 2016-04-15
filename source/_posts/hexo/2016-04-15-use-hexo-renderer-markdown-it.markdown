---
layout: "post"
title: "use-hexo-renderer-markdown-it"
date: "2016-04-15 16:27"
category: hexo
---
use [hexo-renderer-markdown-it][] replace hexo-renderer-marked

### install
```bash
npm un hexo-renderer-marked --save
npm i hexo-renderer-markdown-it --save
```
<!--more-->
### [config][]
```
markdown:
  render:
    html: true
    xhtmlOut: false
    breaks: true
    linkify: true
    typographer: true
    quotes: '“”‘’'
  plugins:
    - markdown-it-abbr
    - markdown-it-footnote
    - markdown-it-ins
    - markdown-it-sub
    - markdown-it-sup
  anchors:
    level: 2
    collisionSuffix: 'v'
    permalink: true
    permalinkClass: header-anchor
    permalinkSymbol: ¶
```

### notice
default `breaks` is `false` need set to `true`
配合atom的markdown-preview `break on single line`
+ issue:[read more][]
```Normally, we insert "<!-- more -->" into a post to display its summary, but don't work if using hexo-renderer-markdown-it with default configuration, hexo-renderer-markdown-it escapes HTML. To fix this issue by appending```

[hexo-renderer-markdown-it]: https://github.com/celsomiranda/hexo-renderer-markdown-it "hexo-renderer-markdown-it"
[config]: https://github.com/celsomiranda/hexo-renderer-markdown-it/wiki/Advanced-Configuration "config"
[read more]: http://lnxpgn.github.io/2015/08/01/hexo-markdown-issues/
