# Patricia Tran
# December 4, 2019

# Generate a network plot with reactions as node, and edges are MAGs, and are colored by taxonomic group.

userprefs <- commandArgs(trailingOnly = TRUE)
R_input_table <- userprefs[1] # Path to folder with all the summary files Energy_flow_input.txt is.
plots.folder.path <- userprefs[2] # Name of new directory to make to store things

if (length(userprefs) > 2){
  mirror.location <- userprefs[3]
}else{
  mirror.location <- "https://cran.mtu.edu"
}

network.plots.folder <- paste(plots.folder.path, "network_plot", sep = "/")
print(network.plots.folder)

library.path <- .libPaths() 

# create directories to hold plots
make.plot.directory <- function(FolderPath){
  if (!dir.exists(FolderPath)){
    dir.create(FolderPath)
    cat("made folder: ", FolderPath, "\n")
  }
}


make.plot.directory(FolderPath = plots.folder.path)
print(network.plots.folder)
dir.create(network.plots.folder)

plot.folder <- network.plots.folder

table <- read.csv(R_input_table, header=T, sep="\t")

#Change the column names

#install.packages("ggraph")
library(ggraph)
library(igraph)

library(tidyverse)

library(tidygraph)

# Edge-width scale built directly with ggplot2: ggraph's default scale passes the
# `trans` argument, which ggplot2 >= 3.5.0 deprecates. Older ggplot2 keeps ggraph's scale.
edge_width_scale <- if (packageVersion("ggplot2") >= "3.5.0") {
  continuous_scale(aesthetics = "edge_width", palette = scales::rescale_pal(c(1, 6)))
} else {
  scale_edge_width_continuous()
}

my_graph <- table[,c(2,3,4,5)] %>% 
  graph_from_data_frame()

deg <- degree(my_graph, mode="all")

# this generates the whole community plot
community.plot <- table[,c(2,3,4,5)] %>% 
  graph_from_data_frame() %>% 
  ggraph(layout = "linear",circular = TRUE) +
  geom_edge_arc(alpha = .25, 
                 aes(width = Coverage.value.average., color=as.factor(Taxonomic.Group))) +
  edge_width_scale +
  geom_node_point(aes(size = deg), color = "black", alpha=0.75) +
  geom_node_text(aes(label = name),  color="black", repel = TRUE)+
  #theme_graph()+
  labs(title = 'Metabolic connections within dataset', 
       subtitle = 'No scaling',
       edge_colour = 'Taxonomic group',
       edge_width = 'Average coverage',
       size = 'Node degree') +
  guides(edge_colour = guide_legend(override.aes = list(edge_alpha = 1, edge_width = 2)))

#community.plot

plot.name <- paste0(network.plots.folder,"/CommunityPlot.PDF")
print(plot.name)

cairo_pdf(filename = plot.name, width = 11, height = 8.5, onefile = TRUE)
community.plot
dev.off()


# this makes a plot for each Taxonomic Group
unique.taxo.groups <- unique(as.character(table$Taxonomic.Group)) #updated as.character to avoid factor issues

for (i in 1:length(unique.taxo.groups)){
  
  print(paste0("Making a plot for: ",unique.taxo.groups[i]))
  
  name.taxo <- unique.taxo.groups[i]
  
  individual.table <- subset(table, table$Taxonomic.Group == unique.taxo.groups[i])
  
  ind.plot <- individual.table[,c(2,3,4,5)] %>%
    graph_from_data_frame() %>% 
    ggraph(layout = "fr") +
    geom_edge_link(alpha = .50, 
                   aes(width = Coverage.value.average.)) +
    edge_width_scale +
    geom_node_point(color = "black", size = 2) +
    geom_node_text(aes(label = name),  color="black", repel = TRUE)+
    theme_graph()+
    labs(title = paste0('Functional connections within ',unique.taxo.groups[i]), 
         subtitle = 'No scaling')
  
  plot.name2 <- paste0(network.plots.folder,"/",name.taxo,".Individual.Taxonomic.Groups.Functional.Network.PDF")
  print(plot.name2)
  
  cairo_pdf(filename = plot.name2, width = 11, height = 8.5, onefile = TRUE)
  print(ind.plot)
  dev.off()
  
  print(i)
  
}

