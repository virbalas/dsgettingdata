## assign working directory
## change this to where the data is stored

setwd('~/coursera/dsgettingdata/work')
getwd()

## read in feature and activity labels
features <- read.table('features.txt')
feature_labels <- gsub("\\(\\)", "", gsub('-', '_', as.vector(features[,2])))
activity_labels <- read.table('activity_labels.txt', col.names = c("ActivityNumber", "ActivityName"))

## read in test & train feature datasets
X_test <- read.table('X_test.txt', col.names = feature_labels)
X_train <- read.table('X_train.txt', col.names = feature_labels)

## drop non mean/std features to speed up processing
X_test_subset_prep <- X_test[c(grep("(_mean_|_std|Mag_mean)", names(X_test), value = TRUE))]
X_train_subset_prep <- X_train[c(grep("(_mean_|_std|Mag_mean)", names(X_train), value = TRUE))]

## oops! a few more unwanted columns remain; remove them
drops <- c("fBodyAccMag_meanFreq","fBodyBodyAccJerkMag_meanFreq","fBodyBodyGyroMag_meanFreq","fBodyBodyGyroJerkMag_meanFreq")
X_test_subset <- X_test_subset_prep[,!(names(X_test_subset) %in% drops)]
X_train_subset <- X_train_subset_prep[,!(names(X_train_subset) %in% drops)]

# import dimensions
y_test <- read.table('y_test.txt', col.names = c("ActivityNumber"))
y_train <- read.table('y_train.txt', col.names = c("ActivityNumber"))
subject_test <- read.table('subject_test.txt', col.names = c("SubjectNumber"))
subject_train <- read.table('subject_train.txt', col.names = c("SubjectNumber"))

## horizontally combne X, y, and subject dataframes
test <- cbind(y_test, subject_test, X_test_subset)
train <- cbind(y_train, subject_train, X_train_subset)

## now append train to test vertically
combined_prep <- rbind(test, train)

## merge on activity labels
combined <- merge(activity_labels, combined_prep, by = 'ActivityNumber')

## produce averages by activity type and subject
combined_means <- aggregate(combined[, 4:69], list(combined$ActivityNumber, combined$ActivityName, combined$SubjectNumber), mean)

## change to clean names for group by vars
install.packages('plyr')
library(plyr)
final_output <- rename(combined_means, c("Group.1"="ActivityNumber", "Group.2"="ActivityName", "Group.3"="SubjectNumber"))

## finally, write it out to a table
write.table(final_output, "output_data.txt", sep = " ", row.name = FALSE)

