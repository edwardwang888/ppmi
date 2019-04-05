library(randomForest)
func_conn <- read.csv("../fMRI_modeling/func_conn.csv")
pd_scores <- read.csv("PD_Scores.csv")
aseg_stats <- read.csv("../fMRI_modeling/aseg_stats.csv")
socio_economics <- read.csv("Socio-Economics.csv")
func_conn <- merge(func_conn, aseg_stats, by.x="Scan", by.y="Measure.volume")

# Remove rows without domain scores
pd_scores <- pd_scores[1:1941,]


## Merge data matrices
data <- data.frame()
prev = 0
for (i in 1:nrow(func_conn)) {
  scan <- func_conn[i,1]
  patno <- strsplit(as.character(scan),'__')[[1]][1]
  if (patno != prev) {
    index1 <- match(patno, pd_scores$PATNO, nomatch=-1)
    index2 <- match(patno, socio_economics$PATNO, nomatch=-1)
    if (index1 != -1 && index2 != -1) {
      # row <- data.frame(func_conn[i,3:ncol(func_conn)], MR6=pd_scores$MR6[index])
      row <- data.frame(PATNO=pd_scores[index1,3],func_conn[i,3:ncol(func_conn)], pd_scores[index1,7:ncol(pd_scores)], HANDED=socio_economics[index2,8])
      # Add row to data
      if (nrow(data) == 0)
        data <- row
      else
        data[nrow(data)+1,] <- row
    }
  }
  prev <- patno
}


## Perform random forests
for (i in 0:5) {
  # Construct matrix with connectivity measures and a single domain score
  my_data <- data[,c(2:74, 75+i)]

  # Construct formula text
  text <- paste(colnames(my_data)[ncol(my_data)], "~", ".")
  func.rf <- randomForest(as.formula(text), data=my_data, type="prob")

  # Modify call text so it is more readable during output
  func.rf$call <- as.name(paste("randomForest(", text, ", data=my_data, type=\"prob\")", sep=""))

  print(func.rf)
  # print(func.rf$importance)
}

## Write data matrix to CSV file
# write.csv(data,"data.csv",quote=FALSE)





# patno_min <-min(pd_scores["PATNO"])
# patno_max <- max(pd_scores["PATNO"])
# # Find first location of each patno
# nsamples <- nrow(pd_scores["PATNO"])
# first_loc <- NA
# for (i in nsamples:1) {
#   patno <- pd_scores["PATNO"][i,]
#   first_loc[patno - patno_min + 1] <- i
# }
