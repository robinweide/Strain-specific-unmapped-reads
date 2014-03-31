read -p "this takes two arguments: input-file and out-file"

bio-table $1 --in-format csv --num-filter 'values.size - values.compact.size > 6' > $2
