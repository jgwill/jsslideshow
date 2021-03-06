#!/bin/bash
#@STCGoal A folder where each jpg are slide showing on the web

cdir=$(pwd)
#source dir - might be different later
sdir=$(pwd)
c=0
wdir=$TMP/build_astia_autosliding
ddir=$cdir/dist
rm -rf $wdir $ddir &>/dev/null
mkdir -p $wdir $ddir &>/dev/null

#@a Cleanup the spacing in files which phoque everything 
for f in *.jpg
do 
  ft=$(echo "$f" | sed -e 's/ /_/g')
  if [ "$ft" != "$f" ]; then 
    mv "$f" "$ft" &> /dev/null
  fi
done

#@a The actual work
for f in *.jpg
do 
    #cap=${f%.*}
    cap=$(sed -e 's/_/ /g'<<<${f%.*})
    cp $f $wdir/$c.jpg
    echo "$cap"
    cp $sdir/htmlblock.html $wdir/$c.html
    cd $wdir
    sed -i 's/MYIMAGE/'"$c.jpg"'/g' $wdir/$c.html
    sed -i 's/MYCAPTION/'"$cap"'/g' $wdir/$c.html
    sed -i 's/CIMG/'"$c"'/g' $wdir/$c.html
    cat $c.html >> $wdir/blocks.html
    cd $cdir
    c=$(expr $c + 1)
done
cd $wdir
#echo "Waiting for phoking dropbox..."
#sleep 3
sed -i 's/TIMG/'"$c"'/g' blocks.html
#@a Integrating Blocks in the final HTML
body=$(cat blocks.html )
cp $sdir/htmlindex.html .
export PATTERN=BODYSLIDE
$binroot/tools/pattern-replacer-awk.sh blocks.html htmlindex.html  > result.html

#@a Auto or Manual Code block (any args will set to manual)
export codefile=$sdir/jscodemanual.js
if [ "$1" == "" ]; then #@state Default to auto
  export codefile=$sdir/jscodeauto.js
fi

export PATTERN=JSCODEBLOCK
$binroot/tools/pattern-replacer-awk.sh  $codefile result.html  > index.html

#@a dist
rm $wdir/blocks.html $wdir/htmlindex.html &>/dev/null
cp $wdir/index.html $ddir
cp $wdir/*.jpg $ddir
cd $ddir
gixb index.html
