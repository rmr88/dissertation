#----------------------#
#  Chapter 3 Figures   #
#----------------------#


### Setup ###

setwd("C:\\Users\\Robbie\\Documents\\dissertation\\Data\\mturkSurvey")

#Libraries
library(ggplot2)
library(dplyr, warn.conflicts=FALSE)
library(grid)
library(gridExtra)
library(scales)

#Function to extract legend, from:
#https://github.com/hadley/ggplot2/wiki/Share-a-legend-between-two-ggplot2-graphs
g_legend<-function(a.gplot){
	tmp <- ggplot_gtable(ggplot_build(a.gplot))
	leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
	legend <- tmp$grobs[[leg]]
	return(legend)}

#Themes
limits.data <- aes(ymax = mean + (se * tcrit), ymin = mean - (se * tcrit))
limits.model <- aes(ymax = ul, ymin = ll)
dodge.data <- position_dodge(width=0.5)
dodge.model <- position_dodge(width=0.25)
theme <- theme_bw() + theme(panel.grid.major.x=element_blank(), 
	panel.grid.minor.x=element_blank(),
	panel.grid.major.y=element_blank(),
	panel.grid.minor.y=element_blank(),
	legend.key=element_blank(), legend.position="bottom")
theme.model <- theme + theme(axis.title.y=element_blank(),
	plot.title=element_text(size=12))
scale.model <- scale_y_continuous(limits=c(-2.5,2.5), breaks=c(-2,-1,0,1,2))
scale.leg <- scale_colour_manual(name="Treatment Condition:",
	values=c("Primed"="black", "Unprimed"="gray50"))


### Data ###

setwd("C:\\Users\\Robbie\\Documents\\dissertation\\Data\\mturkSurvey\\stata output")

#T-Tests
im.data <- read.csv("ttest_im.csv")
im.data$policy <- c("Individual Mandate", "Individual Mandate")

im.data.favor <- read.csv("ttest_im_favor.csv")
im.data.favor$policy <- c("Individual\r\nMandate,\r\nFavor",
	"Individual\r\nMandate,\r\nFavor")
#im.data.favor$policy <- c("Individual Mandate",	"Individual Mandate")
#im.data.favor$op <- c("Favor", "Favor")

im.data.opp <- read.csv("ttest_im_opp.csv")
im.data.opp$policy <- c("Individual\r\nMandate,\r\nDo Not Favor",
	"Individual\r\nMandate,\r\nDo Not Favor")
#im.data.opp$policy <- c("Individual Mandate", "Individual Mandate")
#im.data.opp$op <- c("Oppose", "Oppose")

ya.data <- read.csv("ttest_ya.csv")
ya.data$policy <- c("Dependent Coverage", "Dependent Coverage")

ya.data.favor <- read.csv("ttest_ya_favor.csv")
ya.data.favor$policy <- c("Dependent\r\nCoverage,\r\nFavor",
	"Dependent\r\nCoverage,\r\nFavor")
#ya.data.favor$policy <- c("Dependent Coverage", "Dependent Coverage")
#ya.data.favor$op <- c("Favor", "Favor")

ya.data.opp <- read.csv("ttest_ya_opp.csv")
ya.data.opp$policy <- c("Dependent\r\nCoverage,\r\nDo Not Favor",
	"Dependent\r\nCoverage,\r\nDo Not Favor")
#ya.data.opp$policy <- c("Dependent Coverage", "Dependent Coverage")
#ya.data.opp$op <- c("Oppose", "Oppose")

all.data <- rbind(im.data, ya.data)
all.data.op <- rbind(im.data.favor, im.data.opp, ya.data.favor, ya.data.opp)
#all.data.op.w  <- reshape(all.data.op, idvar=c("policy", "Variable"),
#	timevar="op", direction="wide")

#Models
im.p.model <- read.csv("model_im_p.csv")
im.p.model$cond <- c("Primed")
im.u.model <- read.csv("model_im_u.csv")
im.u.model$cond <- c("Unprimed")

im.model <- rbind(im.p.model, im.u.model)
im.model <- filter(im.model, b != 0)

im.model$Variable <- factor(im.model$Variable,
                            c("3.ideo3", "1.ideo3", "2.pid",
                              "1.pid", "pres_app", "im_op"))
im.model <- filter(im.model, !is.na(Variable))
im.model$ul[im.model$ul > 2.5] <- 2.5

ya.p.model <- read.csv("model_ya_p.csv")
ya.p.model$cond <- c("Primed")
ya.u.model <- read.csv("model_ya_u.csv")
ya.u.model$cond <- c("Unprimed")

ya.model <- rbind(ya.p.model, ya.u.model)
ya.model <- filter(ya.model, b != 0)

ya.model$Variable <- factor(ya.model$Variable,
                            c("3.ideo3", "1.ideo3", "2.pid",
                              "1.pid", "pres_app", "ya_op"))
ya.model <- filter(ya.model, !is.na(Variable))


### Plots ###

setwd("C:\\Users\\Robbie\\Documents\\dissertation\\Analysis\\Figs")

#T-Tests
all.p <- ggplot(all.data, aes(colour=Variable, y=mean, x=policy))
all.fig <- all.p + geom_point(position=dodge.data, size=3, aes(ymax=max(mean))) +
	geom_errorbar(limits.data, width=0.4, position=dodge.data, size=0.5) +
	labs(y="Percent Support for ACA", x="", colour="Treatment\r\nCondition") +
	scale_y_continuous(limits=c(0,1), oob=rescale_none) +	theme + scale.leg
ggsave(all.fig, filename="fig3-2.png", width=8, height=5, units="in")

all.op.p <- ggplot(all.data.op, aes(colour=Variable, y=mean, x=policy))
all.op.fig <- all.op.p + geom_point(position=dodge.data, size=3, 
	aes(ymax=max(mean))) +
	geom_errorbar(limits.data, width=0.4, position=dodge.data, size=0.5) +
	labs(y="Percent Support for ACA", x="", colour="Treatment\r\nCondition") +
  scale_y_continuous(limits=c(0,1), oob=rescale_none) +	theme + scale.leg
ggsave(all.op.fig, filename="fig3-3.png", width=8, height=5, units="in")

#Models
setEPS()
postscript("fig3-4.eps")
im.model.p <- ggplot(im.model, aes(y=b, x=Variable, color=cond))
im.fig <- im.model.p + geom_errorbar(limits.model, position=dodge.model,
	width=0) + geom_point(position=dodge.model, size=3, aes(ymax=max(b))) + 
	labs(title="Individual Mandate Models", y="Coefficients") +
	scale_x_discrete(labels=c("Conservative", "Liberal", "Democrat", "Republican",
	                          "Presidential Approval", "IM Opinion")) + 
	theme.model + scale.leg + scale.model + coord_flip()

ya.model.p <- ggplot(ya.model, aes(y=b, x=Variable, color=cond))
ya.fig <- ya.model.p + geom_errorbar(limits.model, position=dodge.model,
	width=0) + geom_point(position=dodge.model, size=3, aes(ymax=max(b))) + 
	labs(title="Dependent Coverage Models", y="Coefficients") + 
	scale_x_discrete(labels=c("Conservative", "Liberal", "Democrat", "Republican",
	                          "Presidential Approval", "YA Opinion")) + 
	theme.model + scale.leg + scale.model + coord_flip()

legend.obj <- g_legend(ya.fig)
model.fig <- arrangeGrob(im.fig + theme(legend.position="none"),
	ya.fig + theme(legend.position="none"), legend.obj, nrow=3,
	heights=c(10,10,1.5))
plot(model.fig)
#for title in plot, add the following:
#main=textGrob(label="title", gvjust=0.7, p=gpar(fontsize=16))
dev.off()

