#!/bin/bash
# Run this after your rclone transfer has fully completed.
# Steps: (3) verify .fq.gz checksums against local MD5.txt manifests,
#        (4) compress any raw .fq files with pigz,
#        (5) flatten everything into a single compressed_files/ dir.

set -euo pipefail

LOCAL="./lane_files"
OUT="./compressed_files"
mkdir -p "$OUT"

shopt -s globstar nullglob

##############################################
# Step 3: verify checksums for .fq.gz files only
# (MD5.txt manifests only ever covered the originally-uploaded compressed
# files; raw .fq copies have no valid reference here, so they're skipped)
##############################################
echo "== Verifying .fq.gz checksums =="
find "$LOCAL" -iname "*.txt" | while read -r md5file; do
    dir=$(dirname "$md5file")
    echo "  checking $dir"
    while read -r expected fname; do
        [[ "$fname" == *.fq.gz ]] || continue
        target="$dir/$fname"
        if [[ -f "$target" ]]; then
            actual=$(md5sum "$target" | awk '{print $1}')
            if [[ "$actual" == "$expected" ]]; then
                echo "    [ok]   $fname"
            else
                echo "    [FAIL] $fname  expected=$expected got=$actual"
            fi
        fi
    done < "$md5file"
done

##############################################
# Step 4 + 5: copy .fq.gz files as-is, compress raw .fq files, all straight
# into one flat output directory (no intermediate wrapper dirs)
##############################################
NPROC=$(nproc 2>/dev/null || echo 4)

echo "== Copying already-compressed .fq.gz files into $OUT =="
for f in "$LOCAL"/**/*.fq.gz; do
    cp -n "$f" "$OUT/"
done

echo "== Compressing raw .fq files into $OUT =="
for f in "$LOCAL"/**/*.fq; do
    # some .fq entries are actually wrapper directories with a same-named
    # file inside (e.g. .../foo.fq/foo.fq) - resolve to the real file
    if [[ -d "$f" ]]; then
        inner="$f/$(basename "$f")"
        if [[ -f "$inner" ]]; then
            f="$inner"
        else
            echo "  [warn] $f is a directory with no matching file inside, skipping"
            continue
        fi
    fi
    out="$OUT/$(basename "$f").gz"
    if [[ -f "$out" ]]; then
        echo "  skipping $f, $out already exists"
        continue
    fi
    echo "  compressing $f -> $out"
    pigz -p "$NPROC" -c "$f" > "$out"
done

echo ""
echo "Done. Review [FAIL] lines above for anything needing re-download."
echo "Flattened output is in $OUT"
