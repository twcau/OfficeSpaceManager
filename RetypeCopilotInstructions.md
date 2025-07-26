<!-- omit from toc -->
# Retype Documentation Management Instructions for Copilot

## 1. Retype Project Setup

- The documentation site is managed using [Retype](https://retype.com/).
- Source content lives in the `.website/` folder. Never edit files in `docs/` directly; always update `.website/` and run `retype build` to regenerate the site.
- The root of the project contains `retype.yml` for configuration. Reference [Retype configuration docs](https://retype.com/configuration/) for options.
- To build the site, run:
  ```bash
  retype build
  ```
  Output will be in the `docs/` folder.

## 2. Website Structure & Content

- `.website/` is organised by topic:
  - `project-overview/` (idea.md, specification.md, folder-structure.md, design-philosophy.md)
  - `user-guides/` (getting-started.md, backup-and-restore.md, testing.md, menu-structure.md)
  - `issues/` (knownissues.md, todo.md)
  - `contributing/` (CONTRIBUTING.md)
  - `code/` (MODULES.md, API docs)
  - `support/` (support.md, contact.md)
  - `buy-me-a-kofi/` (optional)
  - `index.md` (project landing page)
  - LICENSE.md (project license)
- Each folder/file may include an `index.yml` to control navigation order.

## 3. Document Creation & Editing

- Create new documentation by adding Markdown files to the appropriate `.website/` subfolder.
- Use EN-AU spelling, accessible language, and inclusive formatting.
- Start each Markdown file with `<!-- omit from toc -->` unless otherwise required.
- Use proper Markdown headings, lists, code blocks, and tables for structure and clarity.
- Use relative links for internal references.
- Update navigation/index files (`index.yml`) as needed to maintain order.

## 4. Using Snippets for Retype Content

- Use VS Code snippets to quickly insert Retype-specific blocks, callouts, embeds, panels, tabs, and reference links.
- Example snippet usage:
  - Type the prefix (e.g., `retype-tab-block`) and press `Tab` or `Ctrl+Space` to insert a formatted block.
- Common Retype snippets (see your `retype.code-snippets` file for full list):
  - `retype-page`: Insert a page block with label, layout, order, visibility, and category.
  - `retype-yml`: Insert a YML order block.
  - `retype-callout-*`: Insert callout blocks (base, primary, tip, danger, etc.).
  - `retype-embed`: Insert embed blocks for links or YouTube.
  - `retype-image`: Insert image blocks with title, path, and alt text.
  - `retype-panel`: Insert multi-panel blocks.
  - `retype-ref-link`: Insert reference links.
  - `retype-tab-block`: Insert tabbed content blocks.

## 5. Building & Publishing the Site

- After editing or adding documentation, run `retype build` to regenerate the site.
- Review the output in the `docs/` folder.
- Commit and push changes to the repository to update the published site (if using GitHub Pages or similar).

## 6. Best Practices

- Always keep `.website/` and root documentation in sync.
- Use snippets to maintain consistent formatting and speed up authoring.
- Regularly review for accessibility, inclusive language, and EN-AU spelling.
- Update `retype.yml` and navigation files as the site evolves.
- Document any custom Retype configurations or themes in README.md or CONTRIBUTING.md.

## 7. Troubleshooting

- If snippets do not appear, check VS Code language mode and snippet file syntax.
- If the site does not build, review `retype.yml` and Markdown formatting for errors.
- For advanced configuration, refer to [Retype documentation](https://retype.com/configuration/).

---

**Reference:**  
- [Retype Documentation](https://retype.com/)  
- [OfficeSpaceManager CommonInstructions](see your project for details)  
- Your current VS Code snippets in `retype.code-snippets`
