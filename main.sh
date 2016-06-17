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
				xz -d $target
				echo "${target} was unzipped"
		fi
done

echo "cat *.csv | awk -f name.awk"
cat *.csv | awk -f name.awk > $DICTWORDSFILE
echo "ruby execute.rb"
ruby execute.rb $DICTWORDSFILE $NEWWORDSFILE 1>$STDLOG 2>$ERRLOG 

if [ -e $NEWWORDSFILE ]; then
		LINENUM=`wc -l ${NEWWORDSFILE} | awk '{ print $1 }'`
		if [ ${LINENUM} -ge 100000 ]; then
				echo "${NEWWORDSFILE}は10万行以上存在します。${LINENUM}行です。"
		else
				echo "${NEWWORDSFILE}は10万行に達していません"
		fi
else
		echo "${NEWWORDSFILE}は存在しません"
fi

# xz -z *.csv
