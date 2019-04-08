Alveo R Library
=======

This is the main repository for the R library to interact with the Alveo API


Example Usage:

```R
client <- RestClient(server_uri="app.alveo.edu.au")
client$get_api_version()

results <- client$search_metadata("music")
client$create_item_list(results$items, "Item List 1")
client$get_item_lists()

item_list <- client$get_item_list_by_id(1)
item_list$download("/home/user/R")
item_list$get_items()
item_list$get_item_documents()
item_list$get_segment_list()

item <- item_list$get_item(1)
item$get_metadata()
item$get_indexable_text()
item$get_documents()

document <- item$get_document(1)
document$download("/home/user/R")
```

### Installation

To install this package directly from Github you need the `devtools` library:

```R
  library(devtools)
  install_github('Alveo/alveo-r')
```

### Testing

Tests are written using the 'testthat' package and are in the tests directory.  To run the tests use the 'devtools' library and run the following commands in an R session in the project directory:

```R
library(testthat)
library(devtools)

test()
```

the test can be re-run after changes are made without re-starting the R session (devtools reloads the module).  

