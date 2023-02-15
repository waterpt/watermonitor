library(dplyr)

library(stringr)


##### Taxonomic annotation with GOTTCHA2 #####


# species table with respective relative abundance (only within species-assigned taxa)

# using summary table (no strain information and less columns)

species.table.gottcha <- read.csv("gottcha2.summary.species.csv", header = T)

head(species.table.gottcha)

nrow(species.table.gottcha)


# filtered vertebrate pathogens table (provided by JC). Only pathogen confirmed taxa.

pathogens.table <- read.csv("vertebrates_pathogens.csv", header = T)

head(pathogens.table)

nrow(pathogens.table)


# filtering gottcha output to inlcude only species present in the pathogens table

species.gottcha.pathogens.only <- filter(species.table.gottcha, Species %in% pathogens.table$Species) 

head(species.gottcha.pathogens.only)

nrow(species.gottcha.pathogens.only)

length(unique(species.gottcha.pathogens.only$Species))



##### Taxonomic annotation with Falcon-meta results #####


out_c30 <- read.table("transport_bacteria_water/out_c30.txt") # reading input table

colnames(out_c30) <- c("ID", "size", "perc_simil", "GI_name") # setting column names

out_c30$GI_name <- as.character(out_c30$GI_name) # GI_name as character for text operations


out_c30$genus_info = sapply(strsplit(out_c30$GI_name, "_"), function(x) x[3]) # collecting genus information for each row

out_c30$species_info = sapply(strsplit(out_c30$GI_name, "_"), function(x) x[4]) # collecting species information for each row


out_c30$Species <- paste(out_c30$genus_info, out_c30$species_info, sep = " ") # assigning Species ID for each row

head(out_c30)


# filtering falcon output to inlcude only species present in the pathogens table

species.falcon.pathogens.only.out_c30 <- filter(out_c30, Species %in% pathogens.table$Species) 

head(species.falcon.pathogens.only.out_c30)

nrow(species.falcon.pathogens.only.out_c30)

length(unique(species.falcon.pathogens.only.out_c30$Species))


##### Shared pathogenic species between Gottcha and Falcon ####


# merging gottcha and falcon pathogens

gottcha.falcon.pathogens <- merge(species.gottcha.pathogens.only,species.falcon.pathogens.only.out_c30, by = "Species")

head(gottcha.falcon.pathogens)

nrow(gottcha.falcon.pathogens)

length(unique(gottcha.falcon.pathogens$Species))


write.csv(gottcha.falcon.pathogens, "gottcha.falcon.pathogens.merge.csv")

