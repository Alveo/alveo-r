HCSvLab R Library
=======

This is the main repository for the R library to interact with the HCS vLab API

Documentation for this library can be found [here](https://github.com/IntersectAustralia/hcsvlab-docs/blob/master/RLibrary.md)



Example Usage:

	client <- RestClient(server_uri="app.hcsvlab.org.au")
	client$get_api_version()

	results <- client$search_metadata("music")
	client$create_item_list(results$items, "Item List 1")
	client$get_item_lists()

	item_list <- client$get_item_list_by_id(1)
	item_list$download("/home/user/R")
	item_list$get_items()
	item_list$get_item_documents()

	item <- item_list$get_item(1)
	item$get_metadata()
	item$get_indexable_text()
	item$get_documents()
	item$get_annotations(type="phonetic", label="h")

	document <- item$get_document(1)
	document$download("/home/user/R")