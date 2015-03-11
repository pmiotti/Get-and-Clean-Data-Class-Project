run_analysis <- function() {

        # load labels for features and activities
        features.lbl <- read.table("./features.txt")
        activity.lbl <- read.table("./activity_labels.txt")
        
        # load subjects, features, and activities for both test and train directories
        x.test <- read.table("./X_test.txt")
        y.test <- read.table("./y_test.txt")
        s.test <- read.table("./subject_test.txt")
        
        x.train <- read.table("./X_train.txt")
        y.train <- read.table("./y_train.txt")
        s.train <- read.table("./subject_train.txt")
        
        # merge test and training datasets
        x <- rbind(x.test, x.train)
        y <- rbind(y.test, y.train)
        s <- rbind(s.test, s.train)
        
        # converts all data frames to dplyr tables
        x.tbl <- tbl_df(x)
        y.tbl <- tbl_df(y)
        s.tbl <- tbl_df(s)
        
        # make unique columns names, changing features
        u.features.lbl <- paste(features.lbl$V1, features.lbl$V2)
        
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
        
        # changes all names of columns, using the list in "features
        x.tbl <- select_(x.tbl, .dots = setNames(names(x.tbl), u.features.lbl))
        
        # select all columns with name containing "mean" or "std"
        x.tbl <- select_(x.tbl, .dots = c(~contains("mean()"), ~contains("std()")))
        
        # convert activity code (e.g. 1,2,3,...) to activity description (e.g. WALKING, SITTING, ...)
        # join y.tbl (which contains activiy codes) with activity.lbl (which contrains activity descriptions)
        j.y.tbl <- inner_join(y.tbl, activity.lbl)
        # removes column V1 from j.y.tbl
        j.y.tbl <- select(j.y.tbl, -V1)
        # rename column V2 to the decriptive name "Activity"
        j.y.tbl <- select(j.y.tbl, setNames(V2, "Activity"))
        
        # rename column V1 to the descriptive "Subject" in table s.tbl
        s.tbl <- select(s.tbl, setNames(V1, "Subject"))
                
        # merge Subjects, Activity, and Features in one single table (HAR = Human Activity Recognition)
        har.ds <- cbind(s.tbl, j.y.tbl, x.tbl)
                
        # group and summarise with mean()
        grouped <- group_by(har.ds, Subject, Activity)
        har.sum <- summarise_each(grouped, funs(mean))
        
        return(har.sum)
}