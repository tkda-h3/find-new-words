#!/bin/bash
STDLOG=std.log
ERRLOG=err.log
DICTWORDSFILE=name.log
NEWWORDSFILE=new_words_and_how_to_read.txt

for file in $STDLOG $ERRLOG $DICTWORDSFILE $NEWWORDSFILE; do
		if [ -e $file ]; then
				rm $file
				echo "${file} was removed"
		fi
done
for target in *.csv.xz; do
		if [ -e $target ]; then #まだ辞書csvが圧縮されたまま
				xz -d *.csv.xz
				echo "${target} was unzipped"
		fi
done

cat *.csv | awk -f name.awk > $DICTWORDSFILE
ruby execute.rb $DICTWORDSFILE $NEWWORDSFILE 1>$STDLOG 2>$ERRLOG

if [ -e $DICTWORDSFILE ]; then
		LINENUM=`wc -l ${DICTWORDSFILE}`
		if [${LINENUM} -ge 100000]; then
				echo "${DICTWORDSFILE}は10万行以上存在します"
		else
				echo "${DICTWORDSFILE}は10万行に達していません"
		fi
else
		echo "${DICTWORDSFILE}は存在しません"
fi

# xz -z *.csv
