Alveo R Library
=======

This is the main repository for the R library to interact with the Alveo API


Example Usage:

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
	item$get_annotations(type="phonetic", label="h")

	document <- item$get_document(1)
	document$download("/home/user/R")

### Installation



    
### Testing

Tests are written using the 'testthat' package and are in the tests directory.  To run the tests use the 'devtools' library and run the following commands in an R session in the project directory:

    library(testthat)
    library(devtools)
    
    test()

the test can be re-run after changes are made without re-starting the R session (devtools reloads the module).  

