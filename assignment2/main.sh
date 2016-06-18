#!/bin/bash

STDLOG=std.log
ERRLOG=err.log
WORDSFILE=../name.log
FORTUNEFILE=assignment2.txt
METATMPFILE=meta_tmp.txt

for file in $STDLOG $ERRLOG; do
		if [ -e $file ]; then
				rm $file
				echo "${file} was removed"
		fi
done

if ! [ -e $METATMPFILE ]; then
		echo "ruby consult_kakusuu.rb ${WORDSFILE} ${METATMPFILE} 1>${STDLOG} 2>${ERRLOG}"
		ruby consult_kakusuu.rb $WORDSFILE $METATMPFILE 1>$STDLOG 2>$ERRLOG
fi
echo "wc -l ${METATMPFILE}"
wc -l $METATMPFILE

echo "ruby add_fortune.rb ${METATMPFILE} ${FORTUNEFILE} 1>>${STDLOG} 2>>${ERRLOG}"
ruby add_fortune.rb $METATMPFILE $FORTUNEFILE 1>>$STDLOG 2>>$ERRLOG

if [ -e $FORTUNEFILE ]; then
		LINENUM=`wc -l ${FORTUNEFILE} | awk '{ print $1 }'`
		if [ ${LINENUM} -ge 10000 ]; then
				echo "${FORTUNEFILE}は1万行以上存在します。${LINENUM}行です。"
		else
				echo "${FORTUNEFILE}は1万行に達していません"
		fi
else
		echo "${FORTUNEFILE}は存在しません"
fi
