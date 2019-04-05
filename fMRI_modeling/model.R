library(randomForest)
my_data <- read.csv("func_conn.csv", quote = "")
my_data <- my_data[order(my_data$Group, my_data$Sex, my_data$Age),]

# Get range of indices corresponding to a specific level in a list
getRange <- function(level, list) {
  all_levels <- unique(list)
  index <- match(level, all_levels)
  start <- match(level, list)
  if (index == length(all_levels))
    end <- length(list)
  else
    end <- match(all_levels[index+1], list) - 1
  start:end
}

# Replace GenCohortPD with PD
my_data$Group[getRange("GenCohortPD", my_data$Group)] <- "PD"
my_data <- my_data[order(my_data$Group, my_data$Sex, my_data$Age),]

# Select entries from group2 (larger) based on entries in group1 (smaller)
select <- function(group1, group2) {
  indices <- c()
  arr <- findInterval(group2$Age, group1$Age)
  # Initialize queue to keep track of unmatched elements
  queue <- c()
  for (i in 1:length(group1$Age)) {
    idx <- match(i,arr,nomatch=0)
    if (idx == 0) {
      queue <- c(queue, idx)
    }
    else {
      # Find the minimum between idx and idx-1
      if (idx == 1)
        indices <- c(indices, idx)
      else {
        minimum <- min(idx,idx-1)
        indices <- c(indices, minimum)
        # Add in adjacent elements if queue is nonempty
        if (length(queue) >= 1)
          for (j in 1:length(queue))
            indices <- c(indices, minimum-j)
        queue <- c()
      }
    }
  }
  # In case last index unmatched
  if (length(queue) >= 1)
    for (j in 1:length(queue))
      indices <- c(indices, nrow(group2)-j+1)
  indices <- sort(indices)
  group2[indices,]
}

# Train the model on two groups with group balancing
run <- function(first, second, showImportance=FALSE) {
  # Determine which is group1 and group2 by comparing group sizes
  first_range = getRange(first, my_data$Group)
  second_range = getRange(second, my_data$Group)
  if (length(first_range) > length(second_range)) {
    group1_name = second
    group1_range = second_range
    group2_name = first
    group2_range = first_range
  } else {
    group1_name = first
    group1_range = first_range
    group2_name = second
    group2_range = second_range
  }
  
  # Separate data into group1 and group2, then further by gender
  group1 <- my_data[group1_range,]
  group2 <- my_data[group2_range,]
  group1_male <- group1[getRange("M", group1$Sex),]
  group1_female <- group1[getRange("F", group1$Sex),]
  group2_male <- group2[getRange("M", group2$Sex),]
  group2_female <- group2[getRange("F", group2$Sex),]
  
  # Run random forest
  my_data <- rbind(group1_male, group1_female)
  my_data <- rbind(my_data, select(group1_male, group2_male))
  my_data <- rbind(my_data, select(group1_female, group2_female))
  group1_index <- match(group1_name, levels(my_data$Group))
  group2_index <- match(group2_name, levels(my_data$Group))
  my_data$Group <- droplevels(my_data$Group, except=c(group1_index, group2_index))
  my_data <- my_data[,2:ncol(my_data)]
  func.rf <- randomForest(Group ~ ., data=my_data, type="prob")
  print(func.rf)
  if (showImportance) {
    importance <- sort(func.rf$importance, decreasing=TRUE, index.return=TRUE)
    header <- colnames(my_data)
    header <- header[2:length(header)]
    print(cbind(header[importance$ix], importance$x))
  }
}

run("PD", "Control")
run("PD", "SWEDD")