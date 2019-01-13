#!/bin/sh

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 [ptt]"
	exit 0
fi

echo "finding files..."

find .. -name '*SeriesRange*' | sort > fnames_sr.txt
find .. -name '*Series.csv' | sort > fnames_s.txt

sed '/raw/d' fnames_sr.txt | sed '/$1/!d' > fnames_sr
sed '/raw/d' fnames_s.txt | sed '/$1/!d' > fnames_s

rm fnames_sr.txt
rm fnames_s.txt

COUNTER=0
while read p; do
	COUNT=$(printf "%02d" $COUNTER)
	cp "${p}" "$COUNT"_s_.csv
	let COUNTER=COUNTER+1
done <fnames_s

COUNTER=0
while read q; do
	COUNT=$(printf "%02d" $COUNTER)
	cp "${q}" "$COUNT"_sr.csv
	let COUNTER=COUNTER+1
done <fnames_sr

mv *.csv data/.

echo "generating pngs..."
R CMD BATCH series_summary.R

echo "generating gif..."
convert -delay 50 *.png -loop 0 "$1_series_series.gif"

echo "cleaning up..."
rm olddata/*.*
rm oldimages/*.*
mv data/*.* olddata/.
mv *.png oldimages/.

