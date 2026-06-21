function __fzf_complete_preview -d "Preview handler for fzf tab completion"
    set -l f (string split -- \t -- "$argv[1]")[1]
    set -l f (string trim -r -- "$f")
    set -l f (string replace -r '^~' $HOME -- "$f")

    if test -d "$f"
        if type -q eza
            eza -lah --git --icons --color=always "$f"
        else
            ls -lah "$f"
        end
    else if test -f "$f"
        if type -q bat
            bat --style=numbers --color=always --paging=never --wrap=never "$f"
        else
            cat "$f"
        end
    else if command -q "$f"
        whatis "$f" 2>/dev/null
    else if test -e "$f"
        if type -q eza
            eza -lah --git --icons --color=always "$f"
        else
            ls -lah "$f"
        end
    else
        echo "$f"
    end
end
