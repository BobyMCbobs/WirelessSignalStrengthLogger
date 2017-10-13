#!/bin/bash

#
# wirelessSignalStrengthTester v1 by BobyMCBobs
#
# licensed under GPL 3.0
#

echo "Welcome to signal strength tester -- Where you can monitor the signal strength of your Wireless connection."

function main() {
#init for this program
checkRequirements
chooseWirelessInterface
counterSetup
outputSetup
executeInstructions

}

function checkRequirements() {
#install required packages
if [ ! -f /sbin/iwconfig ]
then
	echo -n "You don't iwconfig installed, would you like to install it? [y/N] "
	read installSetup

	if [ $installSetup = y ]
	then
		sudo apt install net-tools
		checkRequirements
	else
		exit
	fi
fi

}

function chooseWirelessInterface() {
#user selects wireless interfacce
for i in $( ifconfig -a -s | cut -f1 -d' '  | sed -e 's/Iface//g' | sed -e 's/lo//g' | sed '/^\s*$/d' | grep w ); do
        devNetNum=$((devNetNum + 1))
        echo [$devNetNum]: $i

done

echo $'[Q/e]: Quit/Exit\n'
echo -n "Please select your Wireless Interface: "
read wifdr

if [[ $wifdr =~ ^-?[0-9]+$ ]]
then
        wifd=$( ifconfig -a -s | cut -f1 -d' ' | grep w | sed -e 's/Iface//g' | sed -e 's/lo//g' | sed '/^\s*$/d' | sed "${wifdr}p;d" )

else
        wifd=$(echo $wifdr)

fi

if [ $wifdr = "q" ] || [ $wifdr = "Q" ] || [ $wifdr = "e" ] || [ $wifdr = "E" ]
then
        exit
fi

echo "$wifd selected"

}

function counterSetup() {
#how long rounds it should save for, per seconds
echo -n "Please enter seconds to test for (60 = 1 minute): "
read amount

if [[ ! $amount =~ ^-?[0-9]+$ ]]
then
	counterSetup
fi

}

function saveToFile() {
#give location of place to save
echo -n "Please enter location and name of file to save as: "
read fileLocation

if [ $fileLocation = "" ] #|| [  $fileLocation = ]
then
        saveToFile
fi

}

function outputSetup() {
#choose output
echo -n "Where would you like to output to a file or this terminal? [f/T] "
read outputTo

if [ $outputTo = f ] || [ $outputTo = F ]
then
	saveToFile

elif [ $outputTo = t ] || [ $outputTo = T ]
then
	outputPos=""

else
	outputSetup
fi

}

function executeInstructions() {
#run config

if [ $outputTo = t ] || [ $outputTo = T ]
then
	echo "Test begun at: $(date)"

	for i in $(seq $amount -1 1)
	do
		genOutput=$(iwconfig $wifd | grep Signal | awk '{print $4}' )
		echo @$i :: $genOutput dBm
		sleep 1
	done

	echo "Test completed at: $(date)"

elif [ $outputTo = f ] || [ $outputTo = F ]
then
	echo "" > $fileLocation
	echo "Test begun at: $(date)" | tee -a $fileLocation

        for i in $(seq $amount -1 1)
        do
               	genOutput=$(iwconfig $wifd | grep Signal | awk '{print $4}')
               	echo @$i  :: $genOutput dBm | tee -a $fileLocation
               	sleep 1
        done

	echo "Test completed at: $(date)" | tee -a $fileLocation
fi

}

#script init
main
