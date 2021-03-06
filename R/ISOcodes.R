rm(list=ls())
library(tidyverse)
library(xlsx)

################## get the current ISO master list from Github (don't forget to pull) ################## 

ISO_master <- read.csv('ISO-3166-Countries-with-Regional-Codes/all/all.csv',encoding="UTF-8")
ISO_master <- ISO_master %>% 
  select(name,alpha.2,alpha.3,numeric.code=country.code,ISO.region=region) %>% 
  mutate(name=as.character(name))


################## get the world bank regional classification ##################

WB_regions <- read.xlsx('data/CLASS.xls',sheetName = 'List of economies',startRow=5,encoding="UTF-8")
WB_regions <- WB_regions %>% 
  select(WB.name=Economy,code=Code,WB.region=Region,WB.income=Income.group) %>% 
  mutate(WB.name=as.character(WB.name))

# remove aggregates and re-join world 
WB_regions <- WB_regions %>% 
  filter(!is.na(WB.region))

WB_regions <- rbind(WB_regions,data.frame("WB.name"="World","code"="WLD","WB.region"=NA,"WB.income"=NA))

ISO_master <- left_join(ISO_master,WB_regions,by=c("alpha.3"="code"))

ISO_master <- ISO_master %>% 
  mutate(name=ifelse(is.na(WB.name),name,WB.name)) %>% 
  mutate(name=as.factor(name)) %>% 
  mutate(alpha.3=as.factor(alpha.3))

write.xlsx(ISO_master,'output/ISOcodes.xlsx',sheetName='ISO_master',row.names=FALSE)


################## get Julia's extended list of country name alternatives and add ################## 

ISO_alts <- read.xlsx('Data/ISOcodes_old.xls',encoding="UTF-8",sheetName = "3 letter codes",colIndex = 7:8)
names(ISO_alts) <- c("alternative.name","alpha.3")
ISO_alts <- ISO_alts %>% 
  arrange(alpha.3)

########## add any new ones here #########


ISO_alts <- add_row(ISO_alts,alternative.name="NETHERLANDS ANTILLES (FORMER)",alpha.3="ANT")
ISO_alts <- add_row(ISO_alts,alternative.name="Netherlands Antilles",alpha.3="ANT")
ISO_alts <- add_row(ISO_alts,alternative.name="TAIWAN, CHINA",alpha.3="TWN")
ISO_alts <- add_row(ISO_alts,alternative.name="Serbia and Montenegro",alpha.3="SCG")
ISO_alts <- add_row(ISO_alts,alternative.name="JERSEY, CHANNEL ISLANDS",alpha.3="JEY")
ISO_alts <- add_row(ISO_alts,alternative.name="kyrgyz republic",alpha.3="KGZ")
ISO_alts <- add_row(ISO_alts,alternative.name="lao p.d.r.",alpha.3="LAO")
ISO_alts <- add_row(ISO_alts,alternative.name="macao sar",alpha.3="MAC")
ISO_alts <- add_row(ISO_alts,alternative.name="montenegro, rep. of",alpha.3="MNE")
ISO_alts <- add_row(ISO_alts,alternative.name="sã£o tomã© and prã�ncipe",alpha.3="STP")
ISO_alts <- add_row(ISO_alts,alternative.name="bolivarian republic of venezuela",alpha.3="VEN")
ISO_alts <- add_row(ISO_alts,alternative.name="curaçao/netherlands antilles",alpha.3="ANT")
ISO_alts <- add_row(ISO_alts,alternative.name="republic of north macedonia",alpha.3="MKD")
ISO_alts <- add_row(ISO_alts,alternative.name="republic of the congo",alpha.3="COG")




# ISO_alts <- add_row(ISO_alts,alternative.name="bosniaandherzegovina",alpha.3="BIH")
# ISO_alts <- add_row(ISO_alts,alternative.name="burkinafaso",alpha.3="BIH")
# ISO_alts <- add_row(ISO_alts,alternative.name="britishvirginislands",alpha.3="BIH")
# ISO_alts <- add_row(ISO_alts,alternative.name="centralafricanrepublic",alpha.3="BIH")
# ISO_alts <- add_row(ISO_alts,alternative.name="cookislands",alpha.3="BIH")
# ISO_alts <- add_row(ISO_alts,alternative.name="costarica",alpha.3="BIH")







ISO_alts <- rbind(ISO_alts,ISO_master %>% select(alternative.name=name,alpha.3))
ISO_alts <- ISO_alts %>% 
  mutate(alternative.name=tolower(alternative.name)) %>% 
  distinct() %>% 
  arrange(alpha.3)


write.xlsx(ISO_alts,'output/ISOcodes.xlsx',sheetName='alternative_names',row.names=FALSE,append=TRUE)



################## copy to Handy Code for Matlab ################## 

file.copy('output/ISOcodes.xlsx','C:/Users/lamw/Documents/SpiderOak Hive/Work/Code/MATLAB/Handy code')
