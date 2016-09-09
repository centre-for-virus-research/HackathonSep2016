# Written by Quan to do Machine learning and dark seq prediction based on SVM
dataset1 <- read.table('traindata.txt', head = T)
dataset<-dataset1[,-1]
rownames(dataset)<-dataset1[,1]
dataset2 <- read.table('testdata.complex', head = T)
testset<-dataset2[,-1]
rownames(testset)<-dataset2[,1]
library(e1071)
index <- 1:nrow(dataset)
testindex <- sample(index, trunc(length(index)*30/100))
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
datMy.scale<- scale(trainset[2:ncol(trainset)],center=TRUE,scale=TRUE);
corMatMy <- cor(datMy.scale);
jpeg(file="FeatureCorrleation.jpg")
corrplot(corMatMy, order = "hclust")
#visualize the matrix, clustering feature
prediction <- predict(model, testset)  
write.csv(model$SV, file="model_SV.csv")
write.csv(prediction, file="predict_result.csv")
