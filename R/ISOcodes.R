rm(list=ls())
library(tidyverse)
library(xlsx)

################## get the current ISO master list from Github (don't forget to pull) ################## 

ISO_master <- read.csv('ISO-3166-Countries-with-Regional-Codes/all/all.csv',encoding="UTF-8") %>% 
  select(name,alpha.2,alpha.3,region,sub.region)

write.xlsx(ISO_master,'output/ISOcodes.xlsx',sheetName='ISO_master',row.names=FALSE)

################## get Julia's extended list of country name alternatives and add ################## 

ISO_alts <- read.xlsx('Data/ISOcodes_old.xls',encoding="UTF-8",sheetName = "3 letter codes",colIndex = 7:8)
names(ISO_alts) <- c("alternative.name","alpha.3")
ISO_alts <- ISO_alts %>% 
  arrange(alpha.3)

write.xlsx(ISO_alts,'output/ISOcodes.xlsx',sheetName='alternative_names',row.names=FALSE,append=TRUE)

################## copy to Handy Code for Matlab ################## 

file.copy('output/ISOcodes.xlsx','C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/MATLAB/Handy code')
