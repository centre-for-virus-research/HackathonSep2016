# Rscript to query the database and generate a PCA plot of the dark and light contigs based on the different sequence metrics
# e.g.: Rscript PCAplot.r PCA3000.html 3000 *********

args = commandArgs(trailingOnly=TRUE)

if (length(args)!=3) {
  stop("Three arguments must be supplied: output name (e.g. PCA.html) and a size cut-off (e.g. 1500) and password for DB.n", call.=FALSE)
} else if (length(args)==3) {

library(RMySQL)
library(MASS)
library(ggplot2)
library(plotly)
library(devtools)
install_github("vqv/ggbiplot",force=TRUE)
library(ggbiplot)


mydb = dbConnect(MySQL(), user='hack', password=args[3], dbname='Hack', host='127.0.0.1')

rs = dbSendQuery(mydb, "select * from MergeTable")
data = fetch(rs, n=-1)
dbDisconnect(mydb)

data[data=="NULL"] <- NA
data$gc=as.numeric(as.character(data$gc))
data$gcs=as.numeric(as.character(data$gcs))
data$cpg=as.numeric(as.character(data$cpg))
data$cwf=as.numeric(as.character(data$cwf))
data$ce=as.numeric(as.character(data$ce))
data$cz=as.numeric(as.character(data$cz))
data$Length=as.numeric(as.character(data$RefLength))
data$MappedReads=as.numeric(as.character(data$MappedReads))
data$AvDepth=as.numeric(as.character(data$AverageDepth))

subset<-data[data$Length>args[2],]

#dark<-subset[subset$diamond_subjectId=="NA" & subset$blast_subjectId=="NA",]
dark<-subset[is.na(subset$diamond_subjectId) & is.na(subset$blast_subjectId),]
dark$type<-"dark"
light<-subset[!is.na(subset$blast_subjectId) | !is.na(subset$diamond_subjectId),]
light$type<-"light"
all<-rbind(dark,light)

# PCA
# https://www.r-bloggers.com/computing-and-visualizing-pca-in-r/
#all<-read.table("~/Downloads/combinedstudies.txt",sep="\t")
all.stats<-all[c("gc","gcs","cpg","cwf","ce","cz","Length","AvDepth")]
all.type <- all$type


# apply PCA - scale. = TRUE is highly 
# advisable, but default is FALSE. 
all.pca <- prcomp(all.stats,center = TRUE,scale. = TRUE) 
#print(all.pca)
#plot(all.pca, type = "l")
#summary(all.pca)

#predict(all.pca, newdata=tail(all.stats, 2))

g <- ggbiplot(all.pca, obs.scale = 1, var.scale = 1, 
              groups = all.type, ellipse = TRUE, 
              circle = TRUE)
g <- g + scale_color_discrete(name = '')
g <- g + theme(legend.direction = 'horizontal', 
               legend.position = 'top')

#ind.coord<-as.data.frame(all.pca$x)
#ind.coord$type<-all.type
#ind.coord$ContigID<-all[c("contigID")]
#ind.coord$Length<-all[c("Length")]
#g<-ggplot(ind.coord,aes(x=PC1,y=PC2,colour=type))+geom_point(aes(text = paste("ContigID: ", ContigID,"<BR>Length: ", Length,sep="")),size = 1)+theme_bw()

htmlwidgets::saveWidget(as.widget(g), args[1])

}
#print(g)



