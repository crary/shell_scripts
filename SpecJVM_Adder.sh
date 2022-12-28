
#script is used to add numbers within second column of SpecJVM .csv files

cat "$1" | tail +2 | awk -F , '{print $2}' | xargs | sed -e 's/\ /+/g' | bc 