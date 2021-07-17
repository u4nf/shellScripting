#!/bin/bash

#Takes csv file's Students.txt and Marks.txt, 
#generates one pdf file for each student containing student grades


#verify Student.txt and Marks.txt exist otherwise exit
echo "Verifying existance of Student.txt and Marks.txt"

if [ -e Students.txt -a -e Marks.txt ]; then
	echo "OK"
else
	echo "Not found"
	exit 1
fi


#verify Marks.txt is not empty otherwise exit
echo "Verifying Marks.txt is not empty"

if [ -s Marks.txt ]; then
	echo "OK"
else
	echo "Marks.txt is empty, please supply a populated file"
	exit 1
fi


#verify feedbackTemplate.tex exists otherwise exit
echo "Verifying feedbacktemplate.tex exists"

if [ -e feedbackTemplate.tex ]; then
	echo "OK"
else
	echo "Not found"
	exit 1
fi


#verify dir OUTPUT exists otherwise exit
echo "Verifying OUTPUT directory exists"

if [ -d ./OUTPUT ]; then
	echo "OK"
else
	echo "Not found"
	exit 1;
fi

#remove header from Students.txt, replace space with comma for ease of use with for loop
STUDENTLIST=$(grep -E "^u[0-9]{6}" Students.txt | sed s/\ /,/g )
MARKSFILE="Marks.txt"
TEMPLATE="FeedbackTemplate.tex"

#iterate over the list of students and capture details using student number as unique identifier
for line in $STUDENTLIST; do
     		
	STUDENTID=$(echo $line | cut -d "," -f 1)
	
	#substitute comma between first and last names with a space
	STUDENTNAME=$(echo $line | cut -d "," -f 2,3 | sed s/,/\ /) 
	
	
	Q1=$(grep $STUDENTID $MARKSFILE | cut -d "," -f 2)
        Q2=$(grep $STUDENTID $MARKSFILE | cut -d "," -f 3)
        Q3=$(grep $STUDENTID $MARKSFILE | cut -d "," -f 4)
	TOTALGRADE=$(($Q1 + $Q2 + $Q3))
	COMMENTS=$(grep $STUDENTID $MARKSFILE | cut -d "," -f 5)

	#substitute fields in feedbackTemplate.tex with data specific to each student
	echo "Compiling report for $STUDENTID - $STUDENTNAME"
	sed -e "s/STUDENTID/$STUDENTID/"		\
       		-e "s/STUDENTNAME/$STUDENTNAME/" 	\
		-e "s/Q1GRADE/$Q1/" 			\
		-e "s/Q2GRADE/$Q2/" 			\
		-e "s/Q3GRADE/$Q3/" 			\
		-e "s/TOTALGRADE/$TOTALGRADE/" 		\
		-e "s/FINALCOMMENTS/$COMMENTS/" 	\
		feedbackTemplate.tex > ./OUTPUT/$STUDENTID.tex

	#compile pdf, one per student, send to OUTPUT directory
	pdflatex -output-directory OUTPUT ./OUTPUT/$STUDENTID.tex > /dev/null 2>&1
done

echo "Deleting temporary files..."
rm OUTPUT/*.aux OUTPUT/*.log OUTPUT/*.tex

exit 0



