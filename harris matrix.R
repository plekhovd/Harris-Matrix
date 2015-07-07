### Script for managing data export by Access to use in harris matrices

library(dplyr)
library(DiagrammeR)
library(RPostgreSQL)

con <- dbConnect("PostgreSQL", 
                 host='192.168.2.100', 
                 port = '5432', 
                 dbname = 'gygaia', 
                 user = 'gygaiaro', 
                 password = 'gygaiaro')      # create and open the data base connection

area <- c('93', '545')
query <- paste(
'SELECT excavation.contexts.subtable, excavation.contexts.context_number, excavation.contexts_stratigraphic_relationships.stratigraphic_relationship_type, excavation.contexts_stratigraphic_relationships.stratigraphic_relationship_subtype, excavation.contexts_stratigraphic_relationships.related_context_number
FROM excavation.contexts INNER JOIN excavation.contexts_stratigraphic_relationships ON (excavation.contexts.context_number = excavation.contexts_stratigraphic_relationships.context_number) AND (excavation.contexts.area_northing = excavation.contexts_stratigraphic_relationships.area_northing) AND (excavation.contexts.area_easting = excavation.contexts_stratigraphic_relationships.area_easting)
GROUP BY excavation.contexts.area_easting, excavation.contexts.area_northing, excavation.contexts.subtable, excavation.contexts.context_number, excavation.contexts_stratigraphic_relationships.stratigraphic_relationship_type, excavation.contexts_stratigraphic_relationships.stratigraphic_relationship_subtype, excavation.contexts_stratigraphic_relationships.related_context_number
HAVING (((excavation.contexts.area_easting)=',area[1],') AND ((excavation.contexts.area_northing)=',area[2],'))
ORDER BY excavation.contexts.context_number;', sep = '')


db.out <- dbGetQuery(con, query)

dbDisconnect(con)

strat <- db.out %>% tbl_df %>%
     filter(stratigraphic_relationship_type == 'Earlier than') %>%
     select(context_number, related_context_number) %>%
     mutate_each(funs(as.character)) %>%
     transmute(relations = paste(context_number, related_context_number, sep = '-->')) %>%
     t %>%
     paste0(collapse = ';')
strat

diagram.command <- paste("graph BT", strat, sep = ';')
DiagrammeR(diagram.command)




## connecting to the database
## info at https://code.google.com/p/rpostgresql/




