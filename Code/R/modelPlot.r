##################
##  Model Plot  ##
##################

#Libraries
library("diagram")
library("shape")

#Parameters
par(mar = c(0, 0, 0, 0), mfrow = c(1, 1))
names  <- c("Elites", "Public", "", "Representation", "Policy")
M <- matrix(nrow = 5, ncol = 5, byrow = TRUE, data = c(
#  P, E, I, R, Po
   0, "",0, 0, 0, #P
   "",0, 0, 0, 0, #E
   0, 0, 0, 0, "",#I
   "","",0, 0, 0, #R
   0, 0, 0, "",0  #Po
))
curve <- matrix(nrow = 5, ncol = 5, byrow = TRUE, data = c(
#  P,   E,   I, R, Po
   0,   0.1, 0, 0, 0,   #P
   0.1, 0,   0, 0, 0,   #E
   0,   0,   0, 0, 0.4, #I
   0,   0,   0, 0, 0,   #R
   0,   0,   0, 0, 0    #Po
))
arrpos <- matrix(nrow = 5, ncol = 5, byrow = TRUE, data = c(
#  P,   E,   I, R, Po
   0,   0.8, 0, 0, 0,   #P
   0.8, 0,   0, 0, 0,   #E
   0,   0,   0, 0, 0.82,#I
   0.8, 0.8, 0, 0, 0,   #R
   0,   0,   0, 0.75, 0 #Po
))
boxpos <- matrix(nrow = 5, ncol = 2, byrow = TRUE, data = c(
  0.2, 0.2, #P
  0.2, 0.8, #E
  0.4, 0.5, #I
  0.6, 0.5, #R
  0.85, 0.5  #Po
))

#Figure
#png('C:/Users/Robbie/Documents/dissertation/Figs/modelPlot.png')
#postscript('C:/Users/Robbie/Documents/dissertation/Figs/modelPlot.ps')
pp <- plotmat(M, pos = boxpos, name = names,
        curve = curve, arr.pos = arrpos, shadow.size = 0,
        lwd = 1, box.lwd = 1, cex.txt = 0.8,
        box.size = c(0.06, 0.06, 0.03, 0.12, 0.06),
        box.prop = c(0.5, 0.5, 7, 0.25, 0.5),
        box.type = "square")
textplain(c(0.405,0.5), lab = "Institutions", srt = -90)
#dev.off()

#TODO: figure out how to change font