#---------------------#
#  Chapter 1 Figures  #
#---------------------#


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
fig1.1.data <- read.table("data_fig1-1.txt", sep = "\t", header = TRUE)
fig1.2.data <- read.table("data_fig1-2.txt", sep = "\t", header = TRUE)
fig1.3.data <- read.table("data_fig1-3.txt", sep = "\t", header = TRUE)
#fig1.3.data <- read.table("data_fig1-3_ranney.txt", sep = "\t", header = TRUE)


### Figures ###

#Fig 1-1
fig1.1.p <- ggplot(fig1.1.data, aes(x=ptycomp, y=dwnom, color=cat, linetype=cat))
fig1.1 <- fig1.1.p + geom_line() + theme + 
  scale_y_continuous(limits=c(-0.2,1), breaks=c(-0.2,0,0.2,0.4,0.6,0.8,1)) +
  scale_color_manual(values = c("gray70", "black", "black"),
                     breaks = c("Overall", "REP", "DEM"),
                     guide = guide_legend(title=NULL)) +
  scale_linetype_manual(values = c("solid", "solid", "dashed"),
                        breaks = c("Overall", "REP", "DEM"),
                        guide = guide_legend(title=NULL)) +
  labs(y="Change in DW-NOMINATE Score", x="Party Competition")
#fig1.1
ggsave(fig1.1, filename="fig1-1.png", width=8, height=5, units="in")

#Fig 1-2
fig1.2.p <- ggplot(fig1.2.data, aes(x=ptycomp, y=dwnom, color=cat, linetype=cat))
fig1.2 <- fig1.2.p + geom_line() + theme +
  scale_y_continuous(limits=c(-0.2,1), breaks=c(-0.2,0,0.2,0.4,0.6,0.8,1)) +
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
#fig1.2
ggsave(fig1.2, filename="fig1-2.png", width=8, height=5, units="in")

#Fig 1-3
fig1.3.p <- ggplot(fig1.3.data, aes(x=yr, y=b3))
fig1.3 <- fig1.3.p + theme + geom_hline(aes(yintercept=0), size=0.2) +
  geom_errorbar(aes(ymax = b3_ul, ymin = b3_ll), width=0, color="gray40") +
  geom_point() + labs(y="Change in DW-NOMINATE Score", x="Decade") +
  scale_x_continuous(limits=c(1875,2005),
                     breaks=c(1880,1900,1920,1940,1960,1980,2000))
#fig1.3
ggsave(fig1.3, filename="fig1-3_ranney.png", width=8, height=5, units="in")

