# Get-and-Clean-Data-Class-Project
Files for the project assignment in Get and Clean Data Coursera Class

=============================================================================================================
How to set up a working directory, download, and unzip data files.

Even if this is not a necessary step in the current configuration, where all the files are in the same directory,
this can be useful in preparing a clean execution environment.
Create an empty directory which will be the home for developing the data elaboration, for example create a dir named "getdata.project", and then switch to that dir, for example:

> setwd("./getdata.project/")

Download the zip file with the project data, for example, on a Mac OSX:

> download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
                destfile = "./dataset.zip", method = "curl")

Unzip the file:

> unzip("./dataset.zip")

Now, folder "./UCI HAR Dataset" contains all the files and sub-dirs needed for the data elaboration.
You can copy files in the base dir if you want to have them all in the same dir, or change the relative path
in the script to read the datasets from their original location.


=============================================================================================================
run_analysis.R

This is the script which defines function run_analysis(), which performs all the steps as indicated in the 
project assignment:

You should create one R script called run_analysis.R that does the following. 
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable 
   for each activity and each subject.

To perform the complete analysis, once function run_analysis() is defined, run the following command:

> result.tbl <- run_analysis()

result.tbl should the table reflecting the requirements in point number 5.



=============================================================================================================
run_analysis.R Description.

The function starts loading all the provided datasets using read.tabe().
Two tables are used to load descriptions for codes used in datasets:

        features.lbl <- read.table("./features.txt")
        activity.lbl <- read.table("./activity_labels.txt")

"features.lbl" defines descriptive labels for the 561 columns of the X tables (X_test.txt, X_train.txt):

> head(features.lbl)
  V1                V2
1  1 tBodyAcc-mean()-X
2  2 tBodyAcc-mean()-Y
3  3 tBodyAcc-mean()-Z
4  4  tBodyAcc-std()-X
5  5  tBodyAcc-std()-Y
6  6  tBodyAcc-std()-Z

"activity.lbl" decodes activity codes into activity description:

> head(activity.lbl)
  V1                 V2
1  1            WALKING
2  2   WALKING_UPSTAIRS
3  3 WALKING_DOWNSTAIRS
4  4            SITTING
5  5           STANDING
6  6             LAYING

The script continues loading all of the "test" and "training" datasets:

        # load subjects, features, and activities for both test and train directories
        x.test <- read.table("./X_test.txt")
        y.test <- read.table("./y_test.txt")
        s.test <- read.table("./subject_test.txt")
        
        x.train <- read.table("./X_train.txt")
        y.train <- read.table("./y_train.txt")
        s.train <- read.table("./subject_train.txt")

Then, as required by the assignment, the two datasets are combined into a single set of files:

        # merge test and training datasets
        x <- rbind(x.test, x.train)
        y <- rbind(y.test, y.train)
        s <- rbind(s.test, s.train)

When this is complete, all data frames are converted to a more convenient dplyr table by the following:

        # converts all data frames to dplyr tables
        x.tbl <- tbl_df(x)
        y.tbl <- tbl_df(y)
        s.tbl <- tbl_df(s)
        
In "features.txt" some of the labels results duplicate, this is clear from the following command:

> unique(features.lbl$V2)
[473] angle(tBodyGyroMean,gravityMean)     angle(tBodyGyroJerkMean,gravityMean)
[475] angle(X,gravityMean)                 angle(Y,gravityMean)                
[477] angle(Z,gravityMean)                
477 Levels: angle(tBodyAccJerkMean),gravityMean) ... tGravityAccMag-std()

There are 477 unique description, but the table contains more rows:

> dim(features.lbl)
[1] 561   2

This means that using these labels as columns names it doesnÕt work, there would be duplicate column names.
It is then necessary to create unique names to be used as column names, this can be done concatenating the row number and the label itself:


        # make unique columns names, changing features
        u.features.lbl <- paste(features.lbl$V1, features.lbl$V2)
        
Another assignment requirement is to make column names as descriptive as possible, the next code snippet
accomplishes that:

        # change features.lbl to make them descriptive variable names
        u.features.lbl <- gsub(" t", " Time ", u.features.lbl)
        u.features.lbl <- gsub(" f", " Freq ", u.features.lbl)
        u.features.lbl <- gsub("-", " ", u.features.lbl)
        u.features.lbl <- gsub("Body", "Body ", u.features.lbl)
        u.features.lbl <- gsub("Acc", "Acc ", u.features.lbl)
        u.features.lbl <- gsub("Jerk", "Jerk ", u.features.lbl)
        u.features.lbl <- gsub("Gyro", "Gyro ", u.features.lbl)
        u.features.lbl <- gsub("Gravity", "Gravity ", u.features.lbl)
        u.features.lbl <- gsub("  ", " ", u.features.lbl)
        
Then, the 561 descriptions are used as column names in the x.tbl:

        # changes all names of columns, using the list in "features
        x.tbl <- select_(x.tbl, .dots = setNames(names(x.tbl), u.features.lbl))
        
After executing the above code, x.tbl looks like:

   1 Time Body Acc mean() X 2 Time Body Acc mean() Y 3 Time Body Acc mean() Z 4 Time Body Acc std() X
1                 0.2571778              -0.02328523              -0.01465376              -0.9384040
2                 0.2860267              -0.01316336              -0.11908252              -0.9754147
3                 0.2754848              -0.02605042              -0.11815167              -0.9938190
4                 0.2702982              -0.03261387              -0.11752018              -0.9947428
5                 0.2748330              -0.02784779              -0.12952716              -0.9938525
6                 0.2792199              -0.01862040              -0.11390197              -0.9944552
7                 0.2797459              -0.01827103              -0.10399988              -0.9958192
8                 0.2746005              -0.02503513              -0.11683085              -0.9955944
9                 0.2725287              -0.02095401              -0.11447249              -0.9967841
10                0.2757457              -0.01037199              -0.09977589              -0.9983731

Each column name starts with the sequence number, and then uses terms like Time and Frequency, and Body and Acc, and the function applied is reported, for example, as mean().

The next step selects only column related to mean and standard deviation:

        # select all columns with name containing "mean" or "std"
        x.tbl <- select_(x.tbl, .dots = c(~contains("mean()"), ~contains("std()")))
        
Table y.tbl contains codes and not descriptive values, so the next section replaces codes with the corresponding
label:

        # convert activity code (e.g. 1,2,3,...) to activity description (e.g. WALKING, SITTING, ...)
        # join y.tbl (which contains activiy codes) with activity.lbl (which contrains activity descriptions)
        j.y.tbl <- inner_join(y.tbl, activity.lbl)
        # removes column V1 from j.y.tbl
        j.y.tbl <- select(j.y.tbl, -V1)
        # rename column V2 to the decriptive name "Activity"
        j.y.tbl <- select(j.y.tbl, setNames(V2, "Activity"))
        
In table s.tbl, with the list of Subjects, column V1 is renamed as "Subject":

        # rename column V1 to the descriptive "Subject" in table s.tbl
        s.tbl <- select(s.tbl, setNames(V1, "Subject"))
                
Tables with Subjects (s.tbl), activities (j.y.tbl), and measures (s.tbl) are then merged into a single table:

        # merge Subjects, Activity, and Features in one single table (HAR = Human Activity Recognition)
        har.ds <- cbind(s.tbl, j.y.tbl, x.tbl)
                
At the end the function groups the rows of the dataset by Subject and by Activity, and finally it summarizes the rest of the columns calculating the mean. As a last step, the function returns the tidy data set, as required:

        # group and summarise with mean()
        grouped <- group_by(har.ds, Subject, Activity)
        har.sum <- summarise_each(grouped, funs(mean))
        
        return(har.sum)

