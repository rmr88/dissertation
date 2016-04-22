#----------------------#
#  Prospectus Figures  #
#----------------------#


### Setup ###

setwd("C:\\Users\\Robbie\\Documents\\dissertation\\Analysis\\Figs")

#Libraries
library(ggplot2)
library(dplyr, warn.conflicts=FALSE)
library(grid)
library(gridExtra)
library(scales)

#Themes

theme <- theme_bw() + theme(panel.grid.major.x=element_blank(), 
                            panel.grid.minor.x=element_blank(),
                            panel.grid.major.y=element_blank(),
                            panel.grid.minor.y=element_blank(),
                            legend.key=element_blank(), legend.position="bottom")
scale.leg <- scale_colour_manual(values=
                                   c("Overall"="black",
                                     "REP"="gray40",
                                     "DEM" = "black"))

#Data

fig2_data <- read.table("fig2_data.txt", sep = "\t", header = TRUE)
fig3_data <- read.table("fig3_data.txt", sep = "\t", header = TRUE)


### Figures ###

fig2.p <- ggplot(fig2_data, aes(x=ptycomp, y=dwnom, color=cat, linetype=cat))
fig2 <- fig2.p + geom_line() + theme + 
  scale_y_continuous(limits=c(0,1), breaks=c(0,0.2,0.4,0.6,0.8,1)) +
  scale_color_manual(values = c("gray70", "black", "black"),
                     breaks = c("Overall", "REP", "DEM"),
                     guide = guide_legend(title=NULL)) +
  scale_linetype_manual(values = c("solid", "solid", "dashed"),
                        breaks = c("Overall", "REP", "DEM"),
                        guide = guide_legend(title=NULL)) +
  labs(y="Change in DW-NOMINATE Score", x="Party Competition")
fig2
ggsave(fig2, filename="fig2.png", width=8, height=5, units="in")

fig3.p <- ggplot(fig3_data, aes(x=ptycomp, y=dwnom, color=cat, linetype=cat))
fig3 <- fig3.p + geom_line() + theme +
  scale_y_continuous(limits=c(0,1), breaks=c(0,0.2,0.4,0.6,0.8,1)) +
  scale_color_manual(values = c("gray70", "black", "black", "white"),
                     breaks = c("Overall", "Ranney", "HVD"),
                     guide = guide_legend(title=NULL)) +
  scale_linetype_manual(values = c("dotdash", "solid", "dotted", "blank"),
                        breaks = c("Overall", "Ranney", "HVD"),
                        guide = guide_legend(title=NULL)) +
  scale_x_continuous(limits=c(0.5,1), breaks=c(0.5,0.6,0.7,0.8,0.9,1),
                     labels = c("0.5\r\n(10)","0.6\r\n(20)","0.7\r\n(30)",
                                "0.8\r\n(40)","0.9\r\n(50)","1.0\r\n(60)")) +
  labs(y="Change in DW-NOMINATE Score",
       x="Party Competition (HVD Scale in Parentheses)")
fig3 #debug
ggsave(fig3, filename="fig3.png", width=8, height=5, units="in")
