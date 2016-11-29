install.packages("reshape")
library(reshape)

filename <- file.path(getwd(), "getdata_dataset.zip")

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Load activity labels + features
activity <- read.table(file="UCI HAR Dataset/activity_labels.txt",as.is = TRUE)
features <- read.table("UCI HAR Dataset/features.txt",as.is = TRUE)

# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWantedNames <- features[featuresWanted,2]
featuresWantedNames = gsub('-mean', 'Mean', featuresWantedNames)
featuresWantedNames = gsub('-std', 'Std', featuresWantedNames)
featuresWantedNames <- gsub('[-()]', '', featuresWantedNames)

# Load the datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWantedNames)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allDataMelted <- melt(allData, id = c("subject", "activity"))
allDataMean <- cast(allDataMelted, subject + activity ~ variable, mean)

write.table(allDataMean, "tidy.txt", row.names = FALSE, quote = FALSE)
