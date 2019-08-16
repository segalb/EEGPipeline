#make this modular
#maybe even make matlab run this code some day
setwd("/Users/Jeremy/Google_Drive/Grad_School/Dissertation/Interaction_Study/Preprocessing_Pipeline/raw/")

#java and r aren't getting along, so this code won't write. Figure out eventually...

subjects = c(1001)
#REPLACE THESE NUMBERS WITH THE SUBJECT NUMBERS YOU WILL BE USING
#NOTE: If your file names include letters, put them all between quotation marks
#NOTE: If your file names are consecutive (i.e. 101, 102, 103) you can use a colon to indicate this
#i.e. 101:103. You can do that for any consecutive names
#so subjects = c(101:103, 105, 107:111) will work.
#But if you have some names with letters and some without you'll have to put them all in individually
#and put quotations around each one. i.e. subjects = c("101", "102", "103", "105b")

#once you've set the directory and the subject numbers: run everything below!

#install.packages('xlsx') #if you don't have this package, run this line!
require('xlsx')
#incredible website for rJava problems: http://www.snaq.net/software/rjava-macos.php

for (subject in subjects){
  fn_vmrk = paste0(subject, ".vmrk")
  data_bottom <- read.csv(fn_vmrk, sep = ',', skip = 11, header = FALSE) 
  
  data_top <- read.csv(fn_vmrk, header = FALSE, blank.lines.skip = FALSE)
  data_top = data_top[1:12,]
  
  for (i in ncol(data_top):ncol(data_bottom)){
    data_top = cbind(data_top[,1:i], NA)
  }
  data_top[,7] = NULL #I don't know why this bullshit is needed, but it is.
  
  colnames(data_top) <- colnames(data_bottom)
  data_full = rbind(data_top, data_bottom)
  fn_xlsx = paste0(subject, '.xlsx')
  xlsx::write.xlsx(data_full, fn_xlsx, row.names=FALSE, col.names=FALSE, showNA = FALSE)
}
