#!/bin/bash
MAILLOG=/tmp/maillog
UNZIPQUEUE=${MAILLOG}/unzip.queue
ZIPPEDLIST=${MAILLOG}/zipped.list
SEARCHLOG=${MAILLOG}/search.log

echo "Using:" 
echo "Mail log directory: ${MAILLOG}"
echo "Zipped list: ${ZIPPEDLIST}"
echo "Unzip queue: ${UNZIPQUEUE}"

if [ ! -d ${MAILLOG} ]; then
	mkdir ${MAILLOG}
fi

cd ${MAILLOG}
rm -vfr ${MAILLOG}/*

rsync -avh /var/log/mail.log.* ${MAILLOG}/

ls -l /var/log/mail.log*.gz | awk '{ print $9}' > ${ZIPPEDLIST}

cat ${ZIPPEDLIST} | tac > ${UNZIPQUEUE}

while read LINE
do
    echo -n "Gunzipping ${LINE}..."
	gunzip -c ${LINE} >> ${SEARCHLOG}
	echo "[OK]"
done < ${UNZIPQUEUE}

cat /var/log/mail.log.1 >> ${SEARCHLOG}
cat /var/log/mail.log >> ${SEARCHLOG}

grep $1 ${SEARCHLOG}