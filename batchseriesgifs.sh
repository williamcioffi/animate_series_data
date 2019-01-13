#!/bin/sh

./makeseriesgif.sh 454
./makeseriesgif.sh 459
./makeseriesgif.sh 460
./makeseriesgif.sh 466
./makeseriesgif.sh 467
./makeseriesgif.sh 750

echo '******************'
echo 'creating index.html'
rm index.html
printf '%s\n' "<html>" "<body>" "$(date)" "<br><br>" > index.html
cat index.html.part2 >> index.html

echo 'uploading files...'
# scp index.html *.gif PATHHERE

