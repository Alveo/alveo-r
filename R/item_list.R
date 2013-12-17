ItemList <- function(name, uri, items) {
	il = list(
		name = name,
		uri = uri,
		items = items
	)

	il$get_item = function(index) {
		res <- fromJSON(api_request(items[index]))
		return(Item(res$metadata$handle, items[index]))
	}

	il$download = function(destination) {
		#TODO: download item list as zip
	}

	il <- list2env(il)
    class(il) <- "ItemListClass"
    return(il)
}