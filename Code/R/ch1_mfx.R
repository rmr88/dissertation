#-----------------------------------------------#
# Regression Models and Marginal Effects, Ch. 1 #
#-----------------------------------------------#

##Robbie Richards, 3/6/17

### Setup ###

library(interplot)
library(ggplot2)
setwd("C:\\Users\\Robbie\\Documents\\dissertation\\Analysis")

labs <- labs(x = "Party Competition", y = "Change in DW-NOMINATE Score")
theme <- theme_bw() + theme(panel.grid.major.x=element_blank(), 
                      panel.grid.minor.x=element_blank(),
                      panel.grid.major.y=element_blank(),
                      panel.grid.minor.y=element_blank())
scales <- scale_y_continuous(limits = c(0,1))
           

### Individual-level Analysis ###

indiv.data <- read.csv("mfx_indiv_rdata.csv")
indiv.model <- lm(dwnom ~ beta1 + beta2 + beta1*beta2 + beta4 + beta5
                    + south + rep + factor(year)-1,
                  data = indiv.data)
summary(indiv.model)
indiv.plot <- interplot(m = indiv.model, var1 = "beta2", var2 = "beta1")
indiv.plot.formatted <- indiv.plot + theme + labs + scales
indiv.plot.formatted
ggsave(indiv.plot.formatted, filename = "Figs\\fig1-1.png",
       width = 8, height = 5, units = "in")


### Aggregate-level Analysis ###

agg.data <- read.csv("mfx_agg_rdata.csv")
agg.model <- lm(med_dwnom ~ ldv + mn_partyComp + mood + mn_partyComp*mood
                + majPercChamber + dem + midterm, data = agg.data)
summary(agg.model)
agg.plot <- interplot(m = agg.model, var1 = "mood", var2 = "mn_partyComp")
agg.plot.formatted <- agg.plot + theme + labs +
  geom_hline(yintercept = 0) +
  scale_x_continuous(limits = c(0.85,1))
agg.plot.formatted
ggsave(agg.plot.formatted, filename = "Figs\\fig1-2.png",
       width = 8, height = 5, units = "in")

