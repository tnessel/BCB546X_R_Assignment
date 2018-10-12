---
title: "README"
author: "Timothy Nessel"
date: "10/8/2018"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

#BCB546X_R_ASSIGNMENT
##Author: Timothy Nessel

####Setting the Environment
I will start by loading the required packages if required
```{r}
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("ggplot2")) install.packages("ggplot2")
library(tidyverse)
library(ggplot2)
```
We will also need to load the required files from the class github repository. I specify that there is a header, and that the delimiting character is a tab. 
```{r}
fang_et_al_genotypes <- read.table("https://raw.githubusercontent.com/EEOB-BioData/BCB546X-Fall2018/master/assignments/UNIX_Assignment/fang_et_al_genotypes.txt", header = TRUE, sep = "\t")
snp_position <- read.table("https://raw.githubusercontent.com/EEOB-BioData/BCB546X-Fall2018/master/assignments/UNIX_Assignment/snp_position.txt", header = TRUE, sep = "\t")
```
####Inspecting the Files

Using the following commands, we can get some information about our two files, their dimensions, structure, column names, and the first 5 rows of the file:

```{r}
file.info("fang_et_al_genotypes")
dim(fang_et_al_genotypes)
str(fang_et_al_genotypes)
colnames(fang_et_al_genotypes)
head(fang_et_al_genotypes, n = 5)

file.info("snp_position")
dim(snp_position)
str(snp_position)
colnames(snp_position)
head(snp_position, n = 5)
```

####File Processing

We will need to create intermediate tables that only include the genotypes we are interested in, and only include the snp information we are interested in. 

To create our genotype intermediate files, we will a table with only the maize or teosinte group IDs. We will do this with which(), which will return positions when our comparison is TRUE and input them into rows.
```{r}
maize_fang <- fang_et_al_genotypes[which(fang_et_al_genotypes$Group == "ZMMIL" | fang_et_al_genotypes$Group == "ZMMLR" | fang_et_al_genotypes$Group == "ZMMMR"),]


teosinte_fang <- fang_et_al_genotypes[which(fang_et_al_genotypes$Group == "ZMPBA" | fang_et_al_genotypes$Group == "ZMPIL" | fang_et_al_genotypes$Group == "ZMPJA"),]

```

To create our snp intermediate file, we will subset our table with only columns: "SNP_ID" (,1),"Chromosome" (,3), "Position" (,4).
```{r}
snp_position_subset <- snp_position[,c(1,3,4)]
```

Our intermediate genotype files will have to be transposed in order to merge them:
Use column bind to add a new column, SNP_ID, with the row names
```{r}
maize_fang_transposed <- as.data.frame(t(maize_fang[,-1]))
colnames(maize_fang_transposed) <- maize_fang$Sample_ID
teosinte_fang_transposed <- as.data.frame(t(teosinte_fang[,-1]))
colnames(teosinte_fang_transposed) <- teosinte_fang$Sample_ID

teosinte_fang_transposed <- cbind(SNP_ID = row.names(teosinte_fang_transposed), teosinte_fang_transposed)

maize_fang_transposed <- cbind(SNP_ID = row.names(maize_fang_transposed), maize_fang_transposed)
```

We then merge the intermediate files by "SNP_ID" and row names
```{r}
merge_maize <- merge(maize_fang_transposed, snp_position, by = "SNP_ID")
merge_teosinte <- merge(teosinte_fang_transposed, snp_position, by = "SNP_ID")
```

To sort our merged files by increasing and decreasing position, we use the order() function. We also replace 'NA' data with ?/?:
```{r}
merge_maize[merge_maize == "N/A"] <- "?/?"
merge_maize[merge_maize == "NA"] <- "?/?"
merge_teosinte[merge_teosinte == "N/A"] <- "?/?"
merge_teosinte[merge_teosinte == "NA"] <- "?/?"
merge_maize <- merge_maize[order(merge_maize$Position),]
merge_teosinte <- merge_teosinte[order(merge_teosinte$Position),]
merge_maize_reverse <- merge_maize[order(merge_maize$Position,decreasing = T),]
merge_teosinte_reverse <- merge_teosinte[order(merge_teosinte$Position,decreasing = T),]
```

Then we use for loops to subset our datasets by chromosome and write to new files
```{r}
for (i in 1:10){
  merge_maize_chromosome <- merge_maize[merge_maize$Chromosome == i,]
  write.csv(merge_maize_chromosome, file=paste("maize_increasing_",i,".csv",sep=""))
}
for (i in 1:10){
  merge_maize_chromosome_rev <- merge_maize_reverse[merge_maize_reverse$Chromosome == i,]
  merge_maize_chromosome_rev[merge_maize_chromosome_rev == "?/?"] <- "-/-"
  write.csv(merge_maize_chromosome_rev, file=paste("maize_decreasing_",i,".csv",sep=""))
}
for (i in 1:10){
  merge_teosinte_chromosome <- merge_teosinte[merge_teosinte$Chromosome == i,]
  write.csv(merge_teosinte_chromosome, file=paste("teosinte_increasing_",i,".csv",sep=""))
}
for (i in 1:10){
  merge_teosinte_chromosome_rev <- merge_teosinte_reverse[merge_teosinte_reverse$Chromosome == i,]
  merge_teosinte_chromosome_rev[merge_teosinte_chromosome_rev == "?/?"] <- "-/-"
  write.csv(merge_teosinte_chromosome_rev, file=paste("teosinte_decreasing_",i,".csv",sep=""))
}
```
