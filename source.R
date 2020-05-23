# EXTS URL checker (in dev)
# Bobby Stuijfzand 2020

# TO DO: ====
# - Hook up directly to remote repository on GH or even to platform
# - Create GH issues when URLs fail
# - Wrap in an app / Rmd for RStudio connect


library(magrittr)

# user input ====
# set directory
path <- "teamr-fds-src" # set a path to local repo
file_pattern <- "*\\.md$"
files_not_include <- c("[Ff]unctions-[Ii]ndex", "Function-Scope")

# setting up ====
# get files
files <- list.files(path = path, pattern = file_pattern, recursive = TRUE)

# filtering out unwanted files
files <-
  files[purrr::map_lgl(files, ~sum(stringr::str_detect(., files_not_include)) == 0)]

# create paths
file_paths <- file.path(path, files)

# get urls ====
pattern <- "\\(http.+?\\)"

urls <-
  purrr::map(
    file_paths,
    function (x) {
      txt <- suppressWarnings(readtext::readtext(x))

      patterns_in_txt <-
        stringr::str_extract_all(txt$text, pattern) %>%
        unlist() %>%
        stringr::str_sub(2, -2) # remove parentheses
    }
  ) %>%
  setNames(files)

# remove urls we're not interested in: currently links to our own images and to
# our own platform
# also remove empty fields
urls <-
  urls %>%
  purrr::map(
    ~ purrr::discard(., stringr::str_detect, "cloudfront\\.net")
    ) %>%
  purrr::map(
    ~ purrr::discard(., stringr::str_detect, "extensionschool\\.ch")
  ) %>%
  purrr::map(~setNames(., .)) %>%
  purrr::discard(~length(.) == 0)

# test urls ====
results_list <-
  urls %>%
  purrr::map(
    ~purrr::map(.,
                function(x) {
                  tryCatch(
                    httr::HEAD(x) %>% httr::status_code(),
                    error = function (e) print(e$message)
                  )
                })
  ) %>%
  purrr::map(
    ~purrr::discard(., ~. == 200)
  ) %>%
  purrr::discard(~length(.) == 0)

# format output from list to tibble for R printing ====
results_tibble <-
  purrr::map(
    results_list,
    function(x) tibble::tibble(url = names(x),
                               status = as.character(x))
  ) %>%
  dplyr::bind_rows(.id = "unit")

results_tibble
