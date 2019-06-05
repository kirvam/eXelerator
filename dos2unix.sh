# Name: dos2unix.sh
for f
do
mv $f ${f}~ && tr -d "\r" <${f}~ >$f
rm ${f}~
done
