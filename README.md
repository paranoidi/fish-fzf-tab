# fish-fzf-tab

Replace fish's built-in tab-completion pager with an interactive **fzf** selector — preview files, directories, commands, and completions without leaving your terminal.

Inspired by [this gist](https://gist.github.com/developic/643a0384bd911ec09d43850cddf45688).

## Demo

Press Tab and instead of the default pager you get a fuzzy-searchable fzf window showing all completion candidates. Select with arrows / type to filter, and preview the selected item in a split pane:

| What you're completing | Preview shows     |
|------------------------|-------------------|
| Directory path         | `eza -lah` / `ls` |
| File path              | `bat` / `cat`     |
| Command name           | `whatis` output   |
| Anything else          | fallback to `ls`  |

## Requirements

- [fish](https://fishshell.com/) ≥ 3.6
- [fzf](https://github.com/junegunn/fzf) ≥ 0.40

Optional (better previews):
- [eza](https://github.com/eza-community/eza) — colourful directory listings
- [bat](https://github.com/sharkdp/bat) — syntax-highlighted file previews
- [fd](https://github.com/sharkdp/fd) — fast file search fallback

## Install

### With fisher (recommended)

```fish
fisher install paranoidi/fish-fzf-tab
```

### Manual

```fish
git clone https://github.com/paranoidi/fish-fzf-tab ~/.config/fish/fish-fzf-tab
set -U fish_function_path $fish_function_path ~/.config/fish/fish-fzf-tab/functions
```

## Enable

Add this to your **config.fish** to bind Tab → fzf completion:

```fish
bind \t '__fzf_complete'
```

If you ever want to temporarily disable the binding without removing the plugin:

```fish
set -g fish_fzf_tab_disabled 1
```

## Customisation

Pass extra flags to fzf via the `$fzf_complete_opts` variable:

```fish
# Multi-select with ctrl-a to toggle all
set -g fzf_complete_opts --multi --bind=ctrl-a:toggle-all
```

## Files

```
fish-fzf-tab/
├── README.md
├── functions/
│   └── __fzf_complete.fish    # main fzf completion function
└── conf.d/
    └── fish_fzf_tab.fish      # dependency check and binding helper
```

## How it works

1. When Tab is pressed, `__fzf_complete` captures the current command-line buffer and cursor position.
2. It calls fish's own `complete --do-complete "$trimmed"` to get all possible completions for the token under the cursor.
3. Completions are piped into `fzf` with a preview pane that shows file/dir/command info.
4. The selected completion is written back to the command line with `commandline -t`.
5. If no shell completions are available, falls back to an `fd`-based file search.

## License

MIT