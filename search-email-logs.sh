#!/bin/bash
MAILLOG=/tmp/maillog
UNZIPQUEUE=${MAILLOG}/unzip.queue
ZIPPEDLIST=${MAILLOG}/zipped.list
SEARCHLOG=${MAILLOG}/search.log
RESULTS=${MAILLOG}/results.txt
CONF=/etc/mailsearch/mailsearch.conf

if [ -f ${CONF} ]; then
    source ${CONF}
else
    WHITELISTSTRING="Sender address triggers FILTER relay:192.168.3.81"
fi

function reconcat() {

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

}

function showhelp() {
cat <<EOF
SEARCH EMAIL LOGS

Searches email logs (gunzipping and concatenating as necessary) for a given string and disposition.

Syntax:
  search-email-logs.sh [option] [string]

Options:
  -r        Reload and reconcatenated the log files.
  -d        Search for delivered emails (Status=250 OK)
  -w        Search for whitelisted emails
  -j        Search for rejected emails
  -h        Show this help screen.

File support issues at: https://github.com/mjmunger/search-mail-logs

EOF

}

function showresults() {

    cat ${RESULTS}
    #Show count
    COUNT=$(cat ${RESULTS} | wc -l)
    echo ""
    echo "${COUNT} hits"
}

function checkarg() {
    if [ -z $1 ]; then
        errorout $2
    fi
}

function errorout() {
    echo $1
    exit
}

function specialsearch() {
    SEARCHTERM=$1
    FILTER=$2
    grep "${SEARCHTERM}" ${SEARCHLOG} | grep "${FILTER}" > ${RESULTS}
}

echo "Using:"
echo "Mail log directory: ${MAILLOG}"
echo "Zipped list: ${ZIPPEDLIST}"
echo "Unzip queue: ${UNZIPQUEUE}"

if [ ! -d ${MAILLOG} ]; then
	mkdir ${MAILLOG}
	reconcat
fi

cat /dev/null > ${RESULTS}

case $1 in
    "-r")
        reconcat
        echo "All mail files concatenated to ${SEARCHLOG}"
        exit
        ;;
    "-j")
        checkarg $2 "When searching for rejections, use this syntax: 'search-email-logs.sh -j [search string]'"
        specialsearch $2 'reject'
        ;;
    "-d")
        checkarg $2 "When searching for delivered emails, use this syntax: 'search-email-logs.sh -d [search string]'"
        specialsearch $2 '250'
        ;;
    "-w")
        checkarg $2 "When searching for emails delivered via whitelist, use this syntax: 'search-email-logs.sh -w [search string]'"
        specialsearch $2 ${WHITELISTSTRING}
        ;;
    "-h")
        showhelp
        exit
        ;;
    *)
        grep $1 ${SEARCHLOG} > ${RESULTS}
        ;;
esac

showresults