# Get posts data from https://talk.observablehq.com
library(jsonlite)
library(dplyr)
library(glue)

getPosts <- function(json_url) {
  json <- fromJSON(json_url)
  if (length(json$latest_posts) > 0) {
    df <- json$latest_posts %>%
      select(post_id = id, user = username, date = created_at, is_accepted_answer = accepted_answer)
  } else {
    df <- data.frame(post_id="1", user="user", date="2019", is_answer=FALSE)
    df <- df[FALSE,]
  }
  df
}

posts <- getPosts("https://talk.observablehq.com/posts.json")
last_post_id <- tail(posts,1)$post_id
before_post_id <- last_post_id - 1
idx <- 0
step <- 10
maxLoops <- 1000

while (before_post_id >= 0 & idx < maxLoops) {
  Sys.sleep(0.1)
  print(before_post_id)
  idx <- idx + 1
  new_posts <- getPosts(glue("https://talk.observablehq.com/posts.json?before=", before_post_id))
  posts <- rbind(posts, new_posts)
  last_post_id <- tail(posts,1)$post_id
  if (last_post_id <= before_post_id) {
    before_post_id <- last_post_id - 1
  } else {
    before_post_id <- before_post_id - step
  }
}

write.csv(
  data.frame(lapply(posts, as.character), stringsAsFactors=FALSE),
  file = "posts.csv",
  row.names=FALSE)
