<!-- omit from toc -->
# Retype VS Code Snippet Expansion Draft (with Documentation Links)

This document proposes new and improved VS Code snippets for Retype documentation authoring, with inline comments referencing the relevant Retype documentation for each option. All snippets are formatted for direct use in your `.code-snippets` file.

---

## Retype Page Front Matter

```jsonc
"Retype Page Front Matter": {
  "prefix": "retype-page",
  "body": [
    "---",
    "label: ${1:Page Title}", // Explained at https://retype.com/configuration/page/#label
    "layout: ${2:default}", // Explained at https://retype.com/configuration/page/#layout
    "order: ${3:1}", // Explained at https://retype.com/configuration/page/#order
    "visibility: ${4:public|hidden|protected|private}", // Explained at https://retype.com/configuration/page/#visibility
    "category: ${5:overview|howto|module|projectdesign}", // Explained at https://retype.com/configuration/page/#category
    "icon: ${6:book}", // Explained at https://retype.com/configuration/page/#icon
    "expanded: ${7:true|false}", // Explained at https://retype.com/configuration/page/#expanded
    "---"
  ],
  "description": "Insert Retype page front matter with all major options."
}
```

---

## Retype Folder Front Matter

```jsonc
"Retype Folder Front Matter": {
  "prefix": "retype-folder",
  "body": [
    "---",
    "label: ${1:Folder Title}", // Explained at https://retype.com/configuration/folder/#label
    "order: ${2:1}", // Explained at https://retype.com/configuration/folder/#order
    "expanded: ${3:true|false}", // Explained at https://retype.com/configuration/folder/#expanded
    "visibility: ${4:public|hidden|protected|private}", // Explained at https://retype.com/configuration/folder/#visibility
    "---"
  ],
  "description": "Insert Retype folder front matter with all major options."
}
```

---

## Retype Callout Block

```jsonc
"Retype Callout Block": {
  "prefix": "retype-callout",
  "body": [
    "!!!${1:info|tip|warning|danger|success|primary|secondary|question|contrast|ghost|light|dark} ${2:Title}", // Explained at https://retype.com/components/callout/
    "${3:Callout content goes here.}",
    "!!!"
  ],
  "description": "Insert a Retype callout block."
}
```

---

## Retype Tabs Block

```jsonc
"Retype Tabs Block": {
  "prefix": "retype-tabs",
  "body": [
    "+++ ${1:Tab 1}", // Explained at https://retype.com/components/tabs/
    "${2:Content for Tab 1}",
    "+++ ${3:Tab 2}",
    "${4:Content for Tab 2}",
    "+++ ${5:Tab 3}",
    "${6:Content for Tab 3}",
    "+++"
  ],
  "description": "Insert a Retype tabs block."
}
```

---

## Retype Panel Block

```jsonc
"Retype Panel Block": {
  "prefix": "retype-panel",
  "body": [
    "=== ${1:Panel 1}", // Explained at https://retype.com/components/panel/
    "${2:Content for Panel 1}",
    "==- ${3:Panel 2}",
    "${4:Content for Panel 2}",
    "==="
  ],
  "description": "Insert a Retype panel block."
}
```

---

## Retype Embed Block

```jsonc
"Retype Embed Block": {
  "prefix": "retype-embed",
  "body": [
    "[!embed](${1:URL})" // Explained at https://retype.com/components/embed/
  ],
  "description": "Insert a Retype embed block."
}
```

---

## Retype Reference Link

```jsonc
"Retype Reference Link": {
  "prefix": "retype-ref",
  "body": [
    "[!ref ${1:Reference Title}](${2:path/to/file.md})" // Explained at https://retype.com/components/ref/
  ],
  "description": "Insert a Retype reference link."
}
```

---

## Retype Image Block

```jsonc
"Retype Image Block": {
  "prefix": "retype-image",
  "body": [
    "![${1:Alt Text}](${2:path/to/image.png} ${3:Title})" // Explained at https://retype.com/components/image/
  ],
  "description": "Insert a Retype image block."
}
```

---

## GitHub Markdown Callout

```jsonc
"GitHub Markdown Callout": {
  "prefix": "gh-callout",
  "body": [
    "> [!${1:NOTE|TIP|IMPORTANT|WARNING|CAUTION}]", // Explained at https://retype.com/components/callout/
    "> ${2:Callout content goes here.}"
  ],
  "description": "Insert a GitHub-style markdown callout."
}
```

---

## Retype Table Block

```jsonc
"Retype Table Block": {
  "prefix": "retype-table",
  "body": [
    "| ${1:Header 1} | ${2:Header 2} | ${3:Header 3} |", // Explained at https://retype.com/markdown/table/
    "| --- | --- | --- |",
    "| ${4:Row 1 Col 1} | ${5:Row 1 Col 2} | ${6:Row 1 Col 3} |",
    "| ${7:Row 2 Col 1} | ${8:Row 2 Col 2} | ${9:Row 2 Col 3} |"
  ],
  "description": "Insert a markdown table."
}
```

---

## Retype Footnote

```jsonc
"Retype Footnote": {
  "prefix": "retype-footnote",
  "body": [
    "Here is a footnote reference,[^1]", // Explained at https://retype.com/markdown/footnote/
    "",
    "[^1]: ${1:Footnote text.}"
  ],
  "description": "Insert a markdown footnote."
}
```

---

## Retype Definition List

```jsonc
"Retype Definition List": {
  "prefix": "retype-deflist",
  "body": [
    "${1:Term 1}", // Explained at https://retype.com/markdown/definition-list/
    ": ${2:Definition 1}",
    "",
    "${3:Term 2}",
    ": ${4:Definition 2}"
  ],
  "description": "Insert a markdown definition list."
}
```

---

## Retype Task List

```jsonc
"Retype Task List": {
  "prefix": "retype-tasklist",
  "body": [
    "- [ ] ${1:Task 1}", // Explained at https://retype.com/markdown/task-list/
    "- [x] ${2:Task 2 (completed)}",
    "- [ ] ${3:Task 3}"
  ],
  "description": "Insert a markdown task list."
}
```

---

## Retype Horizontal Rule

```jsonc
"Retype Horizontal Rule": {
  "prefix": "retype-hr",
  "body": [
    "---" // Explained at https://retype.com/markdown/horizontal-rule/
  ],
  "description": "Insert a horizontal rule."
}
```

---

## Retype Code Block

```jsonc
"Retype Code Block": {
  "prefix": "retype-code",
  "body": [
    "```${1:language}", // Explained at https://retype.com/markdown/code-block/
    "${2:Code goes here.}",
    "```"
  ],
  "description": "Insert a markdown code block."
}
```

---

**Reference:**

- [Retype Documentation](https://retype.com/)
