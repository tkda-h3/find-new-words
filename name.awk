#cat neologd-*.csv mecab-user-dict-seed.20160613.csv | awk -f name.awk > name.log

BEGIN{
	FS = ","
	OFS = ","
}

{
	if ($7=="人名" && $8=="名")
		print $1
}
