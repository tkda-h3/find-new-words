BEGIN{
	FS = ","
	OFS = ","
}

{
	if ($7=="人名" && $8=="名")
		print $1
}
