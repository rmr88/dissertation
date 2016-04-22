#------------------------------#
#  W-NOMINATE Scores By Topic  #
#------------------------------#

#Robbie Richards, 4/14/16

setwd("C:/Users/Robbie/Documents/dissertation/Data/VoteView")

#Libraries
library(pscl)
library(wnominate)
library(foreign)
library(gdata)

hs <- c("s")

for (i in hs)
{
  for (c in 96:107)
  {
    name <- paste0(i, c)
    print(name)
    
    if (file.exists(paste0("matrices/health_rolls_", name, ".txt")))
    {
      #Read Data
      data <- read.delim(paste0("matrices/health_rolls_", name, ".txt"))
      colnames(data)
      rc <- rollcall(data[,-1], yea = 1, nay = 6, missing = c(8, 9),
                     notInLegis = NA, legis.names = data[,1],
                     desc = paste("Health Bills,", name),
                     vote.names = colnames(data[-1]))
      
      #Scale, write to file
      if (ncol(data) > 20)
      {
        result <- wnominate(rc, dims = 2, minvotes = 10, polarity=c(1,2))
        write.table(format(as.data.frame(result$legislators)), quote = FALSE,
                    file = paste0("results/health_rolls_", name, ".txt"), sep = "\t")
        #column names are off by 1 because the colname for id is absent
      }
    }
  }
}
