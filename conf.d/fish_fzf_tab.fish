# fish-fzf-tab — fzf-powered tab completion for fish
#
# Install via fisher:
#   fisher install paranoidi/fish-fzf-tab
#
# To disable without removing:
#   set -g fish_fzf_tab_disabled 1
#
# Extra fzf flags via $fzf_complete_opts:
#   set -g fzf_complete_opts --multi --bind=ctrl-a:toggle-all

# Dependency check
if not command -q fzf
    echo >&2 "fish-fzf-tab: fzf not found — install from https://github.com/junegunn/fzf"
end

# --- Key bindings (interactive shells only) ---

if status is-interactive
    # Respect opt-out
    if set -q fish_fzf_tab_disabled
        exit 0
    end

    # Bind Tab to fzf completion (won't double-bind on re-source)
    bind \t '__fzf_complete'
end