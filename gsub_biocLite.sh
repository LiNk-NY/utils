#!/bin/bash
# 1 : package name and directory

package=$1

LITE_CALL="biocLite"
BIOC_PKG="BiocInstaller"
SOURCE_FILES=".*\.[Rr]?[DdNnMmWw]*$"
BIOC_MGR="\1\2if (!requireNamespace(\"BiocManager\", quietly=TRUE))\2\\
    \1\2install.packages(\"BiocManager\")\2"

SOURCE_LINE_REGEXP="^(\s*)(\`)*source\(.*http.*$LITE_CALL\.R.*\)\`*\s*$"
LIBRARY_LINE_REGEXP="^\s*library\(.*$BIOC_PKG.*\)\s*$"
BIOCLITE_CALL_REGEXP="^\s*$LITE_CALL\(.*$package.*\)\s*$"

library_hits=`find . ! -path . -regex "$SOURCE_FILES" -exec grep -El "$LIBRARY_LINE_REGEXP" {} \+`

echo "Replacing BiocInstaller with BiocManager..."

for i in $library_hits;
do
    sed -i "s/\<$BIOC_PKG\>/BiocManager/" $i
done

source_hits=`find . ! -path . -regex "$SOURCE_FILES" -exec grep -El "$SOURCE_LINE_REGEXP" {} \+`

echo "Replacing source(*/biocLite.R) with install.packages('BiocManager')"
for i in $source_hits;
do
    sed -E -i "s|$SOURCE_LINE_REGEXP|$BIOC_MGR|" $i
done

biocLite_hits=`find . ! -path . -regex "$SOURCE_FILES" -exec grep -El "$BIOCLITE_CALL_REGEXP" {} \+`

echo "Replacing biocLite() with BiocManager::install()"
for i in $biocLite_hits;
do
    sed -i "s/\<$LITE_CALL\>/BiocManager::install/" $i
done

TOT_FILES="$library_hits $source_hits $biocLite_hits"
TOTAL=`echo $TOT_FILES | tr " " "\n" | uniq | wc -l`

echo "Done. $TOTAL file(s) modified."

