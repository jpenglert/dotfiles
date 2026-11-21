---
name: mermaid-screenshots
description: Render the Mermaid diagrams in a Markdown file to PNG with mmdc, check them by eye, and add them to a GitLab merge request's Screenshots section. Use when asked to render, preview, screenshot or check Mermaid diagrams, or to add diagram images to an MR.
---

# Mermaid screenshots

`mmdc` (Homebrew's `mermaid-cli`) renders each diagram with the same Mermaid major version GitLab uses. Its headless Chrome comes from the chezmoi script `install-mermaid-chrome`.

## Render

1. Pull each ```` ```mermaid ```` block out of the Markdown file into its own `.mmd` file in the scratchpad, numbered in page order. Name each after the heading it sits under.
2. Render each one:

   ```bash
   mmdc -i <name>.mmd -o <name>.png -b white -s 2
   ```

3. If `mmdc` says it can't find `chrome-headless-shell`, Homebrew has upgraded mermaid-cli since the browser was installed. Ask the user to run `chezmoi apply`; don't install a browser yourself.
4. A render error is a syntax error in the diagram. Report the diagram and the message, and fix it in the source before going on.
5. Read every PNG and look at it. Check that no label is cut off, nothing overlaps, and the layout reads in the intended direction. Say what looks wrong instead of uploading it.

## Add to a merge request

Run these from a checkout of the MR's repo, so `:id` resolves to the project.

1. Upload each PNG. The response's `markdown` field is the image link:

   ```bash
   glab api --method POST "projects/:id/uploads" -F "file=@<name>.png" | jq -r .markdown
   ```

   Uploads are visible to everyone who can see the project. Never upload an image that shows a secret, a token, an account ID or an IP address.
2. Get the current description with `glab mr view <iid> -F json | jq -r .description`.
3. Put the images in its `## Screenshots (if appropriate):` section, one `###` heading per diagram, after any output already there. Keep the rest of the description as it is.
4. Show the user the full new description and wait for approval, as the `gitlab-mr` skill requires. Then write it to a file and run `glab mr update <iid> --description "$(cat <file>)"`.
