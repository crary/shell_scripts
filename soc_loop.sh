#! /bin/bash
# Run SocWatch with any number of iteration, wait and record time via user input variables. Script will place SocWatch files
# in number folders, which are automatically compressed into a tarball when finished under user specified name.

i=$1
wait=$2 
record=$3
file_output=$4
count="1"
date=$(date +%Y-%m-%d)
path=/home/socWatch
soc_path=/home/socwatch_chrome_CUSTOM

#Loop socwatch runs, setting iterations, wait and record times (set in seconds).
cd $soc_path
	while [ $i -gt 0 ]; do 
		mkdir $path/soc_run"$count"
		./socwatch --skip-usage-collection -s $wait -t $record -f gfx -f bw-all -f cpu -f sa-freq -f pch-all --option pch-count-always -m -o "$path"/soc_run"$count"/

	i=$(( $i-1 ))
	count=$(( ++count ))
done

#Make a new directory labled from user input, and move all socwatch runs to that directory. 
new_label="$file_output$date"
mkdir $path/$new_label
	mv $path/soc_run* /home/socWatch/$new_label

# Rename SoCwatch files for extra clairity
for f in $path/$new_label/soc_run*/*.csv; do 
	mv "$f" "${f%.*}"_$new_label.csv
done

#compress files
cd "$path"		
tar -czf "$new_label".tar.gz $new_label

#move uncompressed soc files into backup
if [[ ! -d $path/past_socRuns ]]; then
	mkdir $path/past_socRuns
	mv $path/$new_label $path/past_socRuns
else
	mv $path/$new_label $path/past_socRuns 
fi
echo "SocWatch runs finished"
exit
