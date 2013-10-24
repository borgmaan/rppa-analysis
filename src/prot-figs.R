#!/usr/bin/env Rscript
# Andrew Borgman
# VARI BBC
# 10/23/2013
# Making some figs and doing some analysis for BBC RIP pres

library(ggplot2)
library(stringr)
library(reshape2)

## config
.home_dir = "~/projects/prop-odds-pres//"
.data_dir = str_c(.home_dir, "data/")
.image_dir = str_c(.home_dir, "images/")

## data
dat = read.table(str_c(.data_dir, "bn-16-rppa.tsv"), header=T, sep="\t", check.names=F, strip.white=T, as.is=T, stringsAsFactors=F)
hf = read.table(str_c(.data_dir, "hf-rppa.tsv"), header=T, sep="\t", check.names=F, strip.white=T, as.is=T, stringsAsFactors=F)

# Melt it!
melted = melt(data=hf, id.vars=c("Samples", "Sample description"))

# Set all 0 values to NA
melted$value[melted$value <= 0] = NA 

# Let's make this pretty and stick it in our RIP pres...
agg = ddply(.data=melted, .variables=c("variable"), summarize, med=median(value, na.rm=T))
agg = agg[order(agg$med), ]
melted$variable = factor(melted$variable, levels=agg$variable)

long_theme = theme_bw(38) + theme(
  legend.position = "none",
  axis.title.x = element_blank(),
  axis.text.x = element_blank(),
  panel.border = element_rect(size=6),
  axis.ticks.y = element_line(size=3),
  axis.ticks.x = element_blank(),
  axis.ticks.length = unit(x=3, units="mm")
)


# Plot it
p1 = ggplot(data=melted, aes(x=variable, y=value, color=variable)) + 
  geom_jitter(size=2, alpha=.7) +  
  labs(title="Untransformed Protein Expression", ylab="Expresion Level") + 
  long_theme
  
p2 = ggplot(data=melted, aes(x=variable, y=value, fill=variable)) + 
  geom_boxplot(outlier.size=2.5) +  
  labs(title="Untransformed Protein Expression", ylab="Expresion Level") + 
  long_theme

p3 = ggplot(data=melted, aes(x=variable, y=value, fill=variable)) + 
  geom_boxplot(outlier.size=2.5) + ylim(0,500) + 
  labs(title="Zoomed!", ylab="Expresion Level") + 
  long_theme

svg(str_c(.image_dir, "all-prots-hf.svg"), width=18, height=4.5)
p1
dev.off()

svg(str_c(.image_dir, "all-prots-hf-2.svg"), width=16, height=13)
multiplot(p1, p2, p3)
dev.off()

p1 = ggplot(data=melted, aes(x=variable, y=log2(value), color=variable)) + 
  geom_jitter(size=2, alpha=.7) + long_theme + 
  labs(title="Logged Protein Expression", ylab=expression(log[2](Protein~Expression))) 

p2 = ggplot(data=melted, aes(x=variable, y=log2(value), fill=variable)) + 
  geom_boxplot(outlier.size=2.5) +  
  labs(title="Untransformed Protein Expression", ylab="Expresion Level") + 
  long_theme

svg(str_c(.image_dir, "all-logged-prots-hf.svg"), width=16, height=9)
multiplot(p1, p2)
dev.off()


####
## Now some BN plots!
####

# Melt it!
melted = melt(data=dat, id.vars=c("Sample"))

# Set all 0 values to NA
melted$value[melted$value == 0] = NA 

# Let's make this pretty and stick it in our RIP pres...
agg = ddply(.data=melted, .variables=c("variable"), summarize, med=median(value, na.rm=T))
agg = agg[order(agg$med), ]
melted$variable = factor(melted$variable, levels=agg$variable)

# Plot it
p1 = ggplot(data=melted, aes(x=variable, y=value, color=variable)) + 
  geom_jitter(size=2, alpha=.7) +  
  labs(title="BN Untransformed Protein Expression", ylab="Expresion Level") + 
  long_theme

p2 = ggplot(data=melted, aes(x=variable, y=value, fill=variable)) + 
  geom_boxplot(outlier.size=2.5) +  
  labs(title="BN Untransformed Protein Expression", ylab="Expresion Level") + 
  long_theme

p3 = ggplot(data=melted, aes(x=variable, y=value, fill=variable)) + 
  geom_boxplot(outlier.size=2.5) + ylim(0,20000) + 
  labs(title="BN Zoomed!", ylab="Expresion Level") + 
  long_theme

svg(str_c(.image_dir, "bn-all-prots-hf-2.svg"), width=16, height=13)
multiplot(p1, p2, p3)
dev.off()
