rm(list=ls())
library(readr)
library(tidyverse)
library(xlsx)


###################### download latest Geonames database to 'Data/' ###################### 


#http://download.geonames.org/export/dump/  (allCountries.txt)
#http://www.geonames.org/export/codes.html


###################### read and trim allCountries.txt, write to tsv and delete ###################### 


geonames <- read_delim(file='data/allCountries.txt',delim="\t",col_names=FALSE,guess_max=100)
colnames(geonames) <- list('geonameid','name','asciiname','alternatenames','latitude','longitude','feature_class',
                        'feature_code','country_code','cc2','admin1_code','admin2_code','admin3_code','admin4_code',
                        'population','elevation','dem','timezone','modification date')
geonames <- geonames %>% 
  filter(feature_class == 'A' | feature_class == 'L' | feature_class == 'P')

write_tsv(geonames,'data/geonames.tsv')


###################### improve the country name specification using own data ###################### 

geonames <- read_tsv('data/geonames.tsv')
new_geonames <- geonames[0,]


countries <- geonames %>% 
  filter(feature_code == 'PCLI')



messy_names <- read.xlsx('output/ISOcodes.xlsx',sheetName='alternative_names',encoding="UTF-8")
clean_names <- read.xlsx('output/ISOcodes.xlsx',sheetName='ISO_master',encoding="UTF-8")


messy_names <- messy_names %>% 
  group_by(alpha.3) %>% 
  summarise(alternative.name = paste(alternative.name, collapse=";"))

blarg <- left_join(clean_names,messy_names,by=c("alpha.3"="alpha.3"))
blarg$name <- as.character(blarg$name)

blarg <- blarg %>% 
  group_by(alpha.3) %>% 
  mutate(alternative.name = ifelse(is.na(alternative.name),name,alternative.name)) %>% 
  mutate(alternative.name = ifelse(grepl(name,alternative.name),alternative.name,
                                  paste(alternative.name,name,sep=";")))


###################### read and save the geocodes index file ###################### 


geocodes <- read_delim(file='data/featureCodes_en.txt',delim="\t",col_names = FALSE)
colnames(geocodes) <- list('blarg','name','description')
geocodes <- geocodes %>% 
  mutate(feature_class=str_extract(blarg,regex('.(?=(\\.))'))) %>% 
  mutate(feature_code=str_match(blarg,regex('\\.(.*)'))[,-1]) %>% 
  select(feature_class,feature_code,name,description) %>% 
  filter(feature_class == 'A' | feature_class == 'L' | feature_class == 'P')

geocodes$description[geocodes$feature_code=='PCLI'] <- "Countries"

write_tsv(geocodes,'data/geocodes.tsv')



########## improve country name specification ########## 
