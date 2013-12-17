RestClient <- function(server_uri) {
	rc = list(
		server_uri = server_uri
	)

	rc$get_api_version = function() {
		res <- fromJSON(api_request(paste(rc$server_uri, "/version", sep="")))
		return(res$`API version`)
	}

	rc$get_annotation_context = function() {
		res <- fromJSON(api_request(paste(rc$server_uri, "/schema/json-ld", sep="")))
		return(fromJSON(res))
	}

	rc$get_item_lists = function() {
		res <- api_request(paste(rc$server_uri, "/item_lists", sep=""))
		return(fromJSON(res))
	}
	
	rc$get_item_list = function(uri) {
		res <- fromJSON(api_request(uri))
		return(ItemList(res$name, uri, res$items))
	}

	rc$get_item = function(uri) {
		res <- fromJSON(api_request(uri))
		return(Item(res$metadata$handle, uri))
	}

	rc$search_metadata = function(query) {
		query <- URLencode(query)
		res <- api_request(paste(rc$server_uri, "/catalog/search?", query, sep=""))
		return(fromJSON(res))
	}

	rc$download_items = function(items, destination) {
		# TODO: download requested items in zip format
	}

	rc$create_item_list = function(items, name) {
		# TODO: create item list with given items
	}

	rc <- list2env(rc)
    class(rc) <- "RestClientClass"
    return(rc)
}