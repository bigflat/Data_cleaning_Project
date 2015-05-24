rm(list=ls(all=TRUE))
library(plyr)
library(dplyr)
##Download data and add to file
# temp <- tempfile()
# download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp, method = "curl")
# unlink(temp)

# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement. 
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names. 
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#Read all data and labels
test.data  <- read.table('../UCI HAR Dataset/test/X_test.txt',sep = "", header = FALSE)
train.data <- read.table('../UCI HAR Dataset/train/X_train.txt',sep = "", header = FALSE)
sub.test.labels <- read.table('../UCI HAR Dataset/test/subject_test.txt',sep = "", header = FALSE)
sub.train.labels <- read.table('../UCI HAR Dataset/train/subject_train.txt',sep = "", header = FALSE)

act.test.labels <- read.table('../UCI HAR Dataset/test/y_test.txt',sep = "", header = FALSE)
act.train.labels <- read.table('../UCI HAR Dataset/train/y_train.txt',sep = "", header = FALSE)

act.labels <- read.table('../UCI HAR Dataset/activity_labels.txt',sep = "", header = FALSE)
names(act.labels) <- c("activity","activity_label")

heads <- read.table('../UCI HAR Dataset/features.txt',sep = "", header = FALSE)

x = as.character(heads$V2)
names(test.data) = x
names(train.data) = x

bound.test = cbind(sub.test.labels,act.test.labels, test.data)
names(bound.test)[1:2] = c("subject","activity")
bound.train = cbind(sub.train.labels,act.train.labels, train.data)
names(bound.train)[1:2] = c("subject","activity")

######################################################################
# Merges the training and the test sets to create one data set.
######################################################################


all.data = rbind(bound.test, bound.train)

# Extracts only the measurements on the mean and standard deviation for each measurement. 
new.df = all.data[ , grepl( "subject|activity|mean|std"  , names( all.data ) ) ]

######################################################################
# Uses descriptive activity names to name the activities in the data set
######################################################################

new.df$activity = factor(new.df$activity)
new.df$activity = revalue(new.df$activity, c("1"="walking", "2"="walking_upstairs", "3" = "walking_downstairs","4" = "sitting", "5" = "standing", "6" = "laying"))
 
new.df = new.df[ , grepl( "subject|activity|mean"  , names( new.df) ) ]

means = group_by(new.df, subject, activity) %>% summarise_each(funs(mean))
stdev = group_by(new.df, subject, activity) %>% summarise_each(funs(sd))

# gsub("^.*?_","_",names(mean))
names(stdev) = gsub("mean",'stdev',names(stdev))
names(stdev) = gsub("\\(\\)|-",'',names(stdev))
names(means) = gsub("\\(\\)|-",'',names(means))
finalsummary = cbind(means, stdev)

