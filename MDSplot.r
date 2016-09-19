# Rscript to query the database and generate a MDS plot of the dark and light contigs based on the different sequence metrics
# e.g.: Rscript MDSplot.r PCA3000.html 3000 *********

args = commandArgs(trailingOnly=TRUE)

if (length(args)!=3) {
  stop("Three arguments must be supplied: output name (e.g. MDS.html) and a size cut-off (e.g. 3000) and password for DB.n", call.=FALSE)
} else if (length(args)==3) {

library(RMySQL)
library(MASS)
library(ggplot2)
library(plotly)


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

dark<-subset[is.na(subset$diamond_subjectId) & is.na(subset$blast_subjectId),]
dark$type<-"dark"
light<-subset[!is.na(subset$blast_subjectId) | !is.na(subset$diamond_subjectId),]
light$type<-"light"
#all<-rbind(dark,light)
all<-dark
all$Length<-as.numeric(as.character(all$Length))
# uncomment this once database is up and running
#all<-read.table("~/Documents/HackathonSep2016/combinedstudies.txt",sep="\t")


all.stats<-all[c("gc","gcs","cpg","cwf","ce","cz","Length","AvDepth")]
all.type <- all$type

d <- dist(all.stats)
fit <- cmdscale(d,eig=TRUE, k=2) # k is the number of dim
#fit # view results

# plot solution
x <- fit$points[,1]
y <- fit$points[,2]

mdsinfo<-as.data.frame(cbind(x=fit$points[,1],y=fit$points[,2],type=big$type))
mdsinfo$x<-as.numeric(as.character(mdsinfo$x))
mdsinfo$y<-as.numeric(as.character(mdsinfo$y))
mdsinfo$type<-all$type
mdsinfo$ContigID<-all$contigID
mdsinfo$Length<-all$Length
#p<-ggplot(mdsinfo,aes(x=x,y=y,colour=type))+geom_point(aes(text = paste('<a href="http://localhost/hackathon/contigs.php?id=',ContigID,'">ContigID: ', ContigID,"</a><BR>Length: ", Length,sep="")),size = 1)+theme_bw()
p<-ggplot(mdsinfo,aes(x=x,y=y))+geom_point(aes(text = paste('<a href="http://localhost/hackathon/contigs.php?id=',ContigID,'">ContigID: ', ContigID,"</a><BR>Length: ", Length,sep="")),size = 1)+theme_bw()
#(gg <- ggplotly(p))
htmlwidgets::saveWidget(as.widget(p), args[1])
}
