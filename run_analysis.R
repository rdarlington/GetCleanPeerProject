
#set working directory
setwd("C:/Users/rob/Desktop/Courses/01 - Data Science/03 - Getting and Cleaning Data/Project/GettingAndCleaningDataProject")

###1 Merges the training and the test sets to create one data set#####

#load x training data, all data (30%) associated with test subjects
train <- read.table("./UCI HAR Dataset/train/X_train.txt")
#load subject training data, No. from 1-30 on volunteer who performed activity
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
#load y training data, identifies one of six activities
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

#Add trainig data sets together
traindata <- cbind(train, subject_train, y_train)
#rm(train, subject_train, y_train)

#load x testing data, all data (30%) associated with test subjects
test <- read.table("./UCI HAR Dataset/test/X_test.txt")
#load subject data, No. from 1-30 on volunteer who performed activity
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
#load y test data, identifies one of six activities
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
#combine testing data
testdata <- cbind(test, subject_test, y_test)

#combine training and test data
alldata <- rbind(traindata, testdata)



####2 Extracts only the measurements on the mean and standard deviation for each measurement

#Load Column Names 
features <- read.table("./UCI HAR Dataset/features.txt")
last_two <- c("Subject", "Activity")

#t trasponse matrix and return as vector
features <- as.vector(t(features[,2]))
#combine two for all variable names
features <- c(features, last_two)
#assign column names to full data set
colnames(alldata) <- features 


#Extract variables with mean or standard deviation for each measurement
#Identify columns with means
meanCols <- grep(("[Mm]ean()"), names(alldata))
#Identify columns with standard deviation 
standardCols <- grep(("[Ss]td()"), names(alldata))
#Keep subject column
subjectCol <- grep(("Subject"), names(alldata))
#Keep activity column
activityCol <- grep(("Activity"), names(alldata))
colWanted <- c(meanCols,standardCols, subjectCol, activityCol)

#Limit data set to mean and SD
onlySelected <- alldata[,colWanted]

####3 Uses descriptive activity names to name the activiites in the data set
 
#Load activty descriptions
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
#assign column names to activity description data set
colnames(activityLabels) <- c("ActivityID","Activity.Description")
#Merge data frames
onlySelected <- merge(activityLabels, onlySelected, by.x="ActivityID", by.y="Activity") 



### 4 Appropiately labels the data set with descrptive variable names
#Grab variable names
variableNames <- names(onlySelected)
variableNames <- gsub("Acc", "Acceleration", variableNames)
variableNames <- gsub("Body", "Body", variableNames)
variableNames <- gsub("mean", "Mmean", variableNames)
variableNames <- gsub("()-X", "X", variableNames, fixed=TRUE)
variableNames <- gsub("()-Y", "Y", variableNames, fixed=TRUE)
variableNames <- gsub("()-Z", "Z", variableNames, fixed=TRUE)
variableNames <- gsub("Mag", "Magnitude", variableNames)
variableNames <- gsub("-std", "StandardDeviation", variableNames, fixed=TRUE)
variableNames <- gsub("()", "", variableNames, fixed=TRUE)
variableNames <- gsub("-", "StandardDeviation", variableNames, fixed=TRUE)
variableNames <- gsub("^t", "Time", variableNames)
variableNames <- gsub("^f", "Frequency", variableNames)
#Assign Descriptive variable names to data set
colnames(onlySelected) <- variableNames 


## Creates independent tidy data set with the aveage of each variable for each activity
## and each subject

#load plyr package
library(plyr)

subjectActivityMean <- ddply(onlySelected, .(Subject, Activity.Description), colwise(mean))
write.table(subjectActivityMean, "tidy.txt", sep=",", row.name=FALSE)

