Alveo R Library
=======

This is the main repository for the R library to interact with the Alveo API.  It provides access to the API to
query metadata, download item lists and download documents.  


### Installation

To install this package directly from Github you need the `devtools` library:

```R
  library(devtools)
  install_github('Alveo/alveo-r')
```

### Example

To download all text files associated with the items in an item list:

```R
client <- RestClient()

item_list <- client$get_item_list("https://app.alveo.edu.au/item_lists/1")
item_list$download("datadir", "*.txt")
```

To retrieve an individual item:

```R
item <- item_list$get_item(1)
item$get_metadata()
item$get_indexable_text()
item$get_documents()

document <- item$get_document(1)
document$download("datadir")
```

See also the [austalk library](https://github.com/Alveo/austalk-r) for access to the Austalk collection on Alveo.


