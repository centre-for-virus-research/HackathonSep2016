# Written by Quan to do Machine learning and dark seq prediction based on SVM
# Input: (1) InputCotigs.complex : 
# The Output file of profileComplexSeq1.pl with the complexity (e.g. GC content, entropy, etc.) of contigs to be predicted. The header of the file: "ContigID gc gcs cpg cwf ce cz"; 
# (2)traindata.txt : The gold standard TXT file for training the prediction engine with the complexity (e.g. GC content, entropy, etc.) of contigs. The format is almost same with testdata.complex but just with an extra column containing the class of contigs (i.e. dark or light). The header of the file: "ContigID gc gcs cpg cwf ce cz darklight ".

dataset1 <- read.table('traindata.txt', head = T)
dataset<-dataset1[,-1]
rownames(dataset)<-dataset1[,1]
dataset2 <- read.table('InputCotigs.complex', head = T)
inputset<-dataset2[,-1]
rownames(inputset)<-dataset2[,1]
library(e1071)
mysample <- mydata[sample(1:nrow(dataset),100000,replace=FALSE),]# randomly select 100000 samples as dataset
dataset<-mysample
index <- 1:nrow(dataset)
testindex <- sample(index, trunc(length(index)*30/100))
testset <- dataset [testindex,]
trainset <- dataset [-testindex,]
library(doParallel)
cl <- makeCluster(detectCores())
registerDoParallel(cl)
tuned <- best.tune(svm, darklight~ ., data = trainset, kernel = "radial")
model <- svm( darklight~., data = trainset, kernel = "radial", gamma = tuned $gamma, cost = tuned $cost)
stopCluster(cl)
jpeg(file="SVMclassification.jpg")
plot( model , trainset , gcs~gc)
library(corrplot)
datMy.scale<- scale(trainset[1:ncol(trainset)-1],center=TRUE,scale=TRUE);
corMatMy <- cor(datMy.scale);
jpeg(file="FeatureCorrleation.jpg")
corrplot(corMatMy, order = "hclust")
predicttest <- predict(model, testset) 
predicttest <- predict(model, testset[,-7])  #The -1 is because the label column to intance classes, V1, is in the first column
tab <- table(pred = predicttest, true = testset[,7])
acc<-(tab[1,1]+tab[2,2])/sum(tab)
prediction <- predict(model, inputset)  
write.csv(model$SV, file="model_SV.csv")
write.csv(prediction, file="predict_result.csv")
write.csv(acc,file="predict_accuracy.csv")
