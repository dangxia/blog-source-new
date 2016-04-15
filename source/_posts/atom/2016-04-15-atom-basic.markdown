---
layout: "post"
title: "atom-basic"
date: "2016-04-15 16:48"
category: atom
---
使用atom编辑markdown,大概了解一下怎么使用,参考[Atom 使用教程][1]
### 常用快捷键

快捷键          | 效果
----------------|-----------------------------------------------------------------
cmd + comma     | open preferences
cmd + shift + p | toggle command palette
cmd + \         | toggle tree view
cmd + shift + k | delete whole line(eclipse:cmd + d,**和markdown-writer热键冲突**)
cmd + shift + d | duplicate whole line

<!--more-->

### markdown-writer keybindings
```
".platform-linux atom-text-editor:not([mini])":
  "shift-ctrl-K": "markdown-writer:insert-link"
  "shift-ctrl-I": "markdown-writer:insert-image"
  "ctrl-i":       "markdown-writer:toggle-italic-text"
  "ctrl-b":       "markdown-writer:toggle-bold-text"
  "ctrl-'":       "markdown-writer:toggle-code-text"
  "ctrl-h":       "markdown-writer:toggle-strikethrough-text"
  "ctrl-1":       "markdown-writer:toggle-h1"
  "ctrl-2":       "markdown-writer:toggle-h2"
  "ctrl-3":       "markdown-writer:toggle-h3"
  "ctrl-4":       "markdown-writer:toggle-h4"
  "ctrl-5":       "markdown-writer:toggle-h5"
```

### notice
atom 不支持`零宽度正回顾后发断言`,同样[kate也不支持][2].
`esc` 可以关闭,finder,markdown-link-insert等窗口

[1]:http://wiki.jikexueyuan.com/project/atom/split-screen-operation.html
[2]:https://www.kate-editor.org/doc/kate-part-find-replace.html
