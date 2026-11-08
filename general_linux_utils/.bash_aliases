# Alias micromamba as conda
alias conda="micromamba"

# Aliases for obsidian conflict resolution ----
# find conflicts
alias find_conflicts='find ./ -name "*conflict*"'

# git diff native vs conflicted file (use: diffconflict <file_no extension> <ext(no dot); if not default .json>)
diffconflict() {
    local base="$1" ext="${2:-json}"
    git diff --no-index -- "$base.$ext" "$base (conflict "*").$ext"
}
