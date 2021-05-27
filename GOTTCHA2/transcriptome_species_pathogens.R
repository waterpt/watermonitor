# Transcriptome sample from WWTP of Cov2 project 
# Sample ID: C2F2a

# taxonomic annotation with GOTTCHA2 

# species table with respective relative abundance (only within species-assigned taxa)
# using summary table (no strain information and less columns)
species.table <- read.csv("gottcha2.summary.species.csv", header = T)
head(species.table)
nrow(species.table)

# filtered vertebrate pathogens table (provided by JC). Only pathogen confirmed taxa.
pathogens.table <- read.csv("vertebrates_pathogens.csv", header = T)
head(pathogens.table)
nrow(pathogens.table)

# merge identified species with pathogens table
# keeping the species not identified wiht the pathogens
species.pathogens <- merge(species.table,pathogens.table, by = "Species", all.x = T)
head(species.pathogens)
nrow(species.pathogens)
write.csv(species.pathogens, "species_pathogens.csv")
