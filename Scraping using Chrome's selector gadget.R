remove(list = ls(all = T)); gc(T,T,T)

if (!require(tidyverse))
install.packages("tidyverse", repos = "http://cran.us.r-project.org")

if (!require(rvest)) 
install.packages("rvest", repos = "http://cran.us.r-project.org")


# First, we have to store the permanent Spotify-link to an object.

url <- "https://spotifycharts.com/regional/de/daily/"

# Here we specify the entire streaming period (i.e., the sequence of 546 days).

streaming_period <- seq(as.Date("2019/01/01"), as.Date("2020/06/29"), 
                        by = "day")

# Next, we write a generic function that combines or, respectively, concatenates 
# the URLs (for the entire period) by taking the permanent link from above and a 
# blank argument (such as x) as another object to which the URL should depend 
# (i.e., our streaming_period).
 
gathering_urls <- function(x){paste0(url, x)}

# Using the just created function to apply it on the streaming period to finally
# get those 546 definitive URLs.

all_urls  <- gathering_urls(streaming_period)

# Everything looks fine thus far. Hence, we create now a function that fills
# the desired column-names with the information we are going to retrieve from those 546 URLs 
# (i.e., chart position, song/track title, artist, stream counts, and dates).

spotifyR_scrapeR <- function(x) {page <- x

# Retrieving the 200 chart positions of each day.

chart_position <- page %>% 
                  read_html() %>% 
                  html_nodes(".chart-table-position") %>% 
                  html_text()

# Retrieving the 200 song/track titles of each day.

title <- page %>% 
         read_html() %>% 
         html_nodes("strong") %>% 
         html_text()
           
# Retrieving the 200 artist names of each day.

artist <- page %>% 
          read_html() %>% 
          html_nodes(".chart-table-track span") %>% 
          html_text()
                            
# Retrieving the 200 stream counts of each day.

stream_count <- page %>% 
                read_html() %>% 
                html_nodes("td.chart-table-streams") %>% 
                html_text()

# Retrieving the dates of for each day of the period. 
            
date <- page %>% 
        read_html() %>% 
        html_nodes(".responsive-select~ .responsive-select+ 
                    .responsive-select .responsive-select-value") %>%
        html_text()

# Putting these chunks together in a table of the class. 

tab <- data.frame(chart_position, title, artist, stream_count, date)

return(tab)}

# As the amount of data that should be retrieved is not that small, we can 
# expect that this process will take some time. To know how long this process
# will last, we calculate the difference between the process initialization and 
# its end.

init_time <- Sys.time()

# The actual process of web scraping: Applying the spotifyR_scrapeR-function
# to the object of that all URLs. That is, the just 
# created spotifyR_scrapeR-function retrieves from each URL the desired 
# information.

spotifyR <- map_df(all_urls, spotifyR_scrapeR) 

# End time of the retrieving-process.

end_time <- Sys.time()

# Difference (i.e., processing time to retrieve the desired information).

process_time <- end_time - init_time
print(process_time)

# Exporting and saving the retrieved datatable as .csv-file.
write_csv(spotifyR, "spotifyR_Charts_orig.csv")
