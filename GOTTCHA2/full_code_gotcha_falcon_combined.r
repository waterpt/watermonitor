#Code for figures and pre-processing of data for circos figures
# Falcon and GOTCHA

#load necessary packages
pks <- c("readxl","dplyr","ggplot2","ggpubr")
lapply(pks,library,character.only=T)

# FALCON

##load data

falcon_data <- 
  read_xlsx("supplementary_data/Supplementary Table S2.xlsx",sheet= "Supplementary Table S2")

#select relevant variables

##list of unnecessary hosts
falcon_data$Percentage_similarity <- as.numeric(falcon_data$Percentage_similarity)
falcon_data_clean <- falcon_data %>% select(Species, Percentage_similarity,Association,HostName,Genome.size,Type) %>% 
  filter(Association == "Pathogenic",HostName == "Human") %>% 
  group_by(Species) %>%
  mutate(Mean_percentage_similarity = mean(Percentage_similarity)) %>%
  ungroup() %>% 
  select(-Percentage_similarity) %>%  
  distinct() %>% 
  arrange(Type)
##


##more cleaning...
#remove spaces from Species
falcon_data_clean <- falcon_data_clean %>% mutate(Species = gsub(" ","_",Species))
#sp. to species to avoid problems with the dot
falcon_data_clean <- falcon_data_clean %>% mutate(Species = gsub("sp.","species",Species))


png("./Falcon_species.png")
falcon_data_clean %>% 
  ggplot(aes(x=reorder(Species,-Mean_percentage_similarity),
             y=Mean_percentage_similarity,
             fill=as.numeric(Genome.size)))+
  geom_point(shape = 21) +
  coord_flip() + 
  labs(y = "Mean percentage of similarity",
       title = "FALCON-META",
       fill = "Genome size (Gbp)",
       x="Species")+
  ylim(c(0,100))+
  theme_pubclean()+
  theme(axis.text.y = element_text(face = "italic"))+
  scale_fill_gradient2()
dev.off()

## GOTCHA 

##load data

gotcha_data <- read_xlsx("./supplementary_data/Supplementary Table S1.xlsx",sheet= "Supplementary Table S1")

##clean table

#select relevant variables

##list of unnecessary hosts

gotcha_data_clean <- gotcha_data %>% select(Species, READ_COUNT,REL_ABUNDANCE,Association,Human,HostName,Type) %>% 
  filter(HostName %in% c("NA","Human"),Association == "Pathogenic")
##more cleaning...
#remove spaces from Species
gotcha_data_clean <- gotcha_data_clean %>% mutate(Species = gsub(" ","_",Species))
#sp. to species to avoid problems with the dot
gotcha_data_clean <- gotcha_data_clean %>% mutate(Species = gsub("sp.","species",Species))

png("../GOTCHA_figure.png")
gotcha_data_clean %>% 
  ggplot(aes(x=reorder(Species,-READ_COUNT),
             y=READ_COUNT,
             fill=as.numeric(REL_ABUNDANCE)))+
  stat_summary(shape = 21) +
  coord_flip() + 
  labs(title = "GOTTCHA2",
       fill = "Relative abundance",
       y = "Number of sequences (Log10 scale)",
       x = "Species")+
  theme_pubclean()+
  theme(axis.text.y = element_text(face = "italic"),
        legend.text = element_text(angle = 90,vjust = 0.5))+
  scale_fill_gradient2()+
  scale_y_log10()
dev.off()


##Combined 

##Add a marker of the origin of each table
gotcha_data_clean$Var <- "var1"
falcon_data_clean$Var <- "var2"

##merge

combined_data <- gotcha_data_clean %>% full_join(falcon_data_clean)
#make colors for species names
combined_data <- combined_data %>% mutate(color = ifelse(Type == "Bacteria","color=black","color=grey"))


##
conf_table <- tibble(var= combined_data$Var,p0=c(1:c(dim(combined_data)[1])),p1=c(2:c(dim(combined_data)[1]+1)),
                     Species = combined_data$Species,
                     Read_count = combined_data$READ_COUNT,
                     Rel_abundance = combined_data$REL_ABUNDANCE,
                     Association = combined_data$Association,
                     Percentage_similarity = combined_data$Mean_percentage_similarity,
                     Genome_size = combined_data$Genome.size,
                     colors = combined_data$color)
conf_table$Rel_abundance <- as.numeric(conf_table$Rel_abundance)

##Turn all variables into relative values to avoid problems in the circos plot

##NAs wont make sense in circos, turn them into 0;
conf_table <- conf_table %>%
  mutate(across(where(is.numeric), ~ ifelse(is.na(.), 0, .)))

#Species_text

species_text <- conf_table %>% select(var,p0,p1,Species,colors)
write.table(species_text,"./data/species_text",quote=F,row.names = F,col.names=F)

#Histogram with relative abundance

hist_ra <- conf_table %>% select(var,p0,p1,Rel_abundance)
write.table(hist_ra,"./data/hist_ra",quote=F,row.names = F,col.names=F)

#histogram with read count

hist_rc <- conf_table %>% select(var,p0,p1,Read_count)
write.table(hist_rc,"./data/hist_rc",quote=F,row.names = F,col.names=F)

##histogram with Percent similarity
hist_ps <- conf_table %>% select(var,p0,p1,Percentage_similarity)
write.table(hist_ps,"./data/hist_ps",quote=F,row.names = F,col.names=F)

##histogram with genome size
hist_gs <- conf_table %>% select(var,p0,p1,Genome_size)
write.table(hist_gs,"./data/hist_gs",quote=F,row.names = F,col.names=F)

##make link file

##get common species to both approaches

common_species <- inner_join(falcon_data_clean,gotcha_data_clean,by=c("Species")) %>% select(Species)


common_species_coordinates <- conf_table %>% filter(Species %in% common_species$Species) %>% select(Species,var,p0,p1)

link_1 <- common_species_coordinates %>% filter(var == "var1") #%>% select(var,p0,p1)
link_2 <- common_species_coordinates %>% filter(var == "var2") #%>% select(var,p0,p1)
links <- left_join(link_1,link_2,by="Species")
links$colors <- "color=pastel1-4-qual-4"
links$Species <- NULL
#
write.table(links,"./data/links",quote=F,row.names = F,col.names=F)
