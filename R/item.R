Item <- function(id, uri) {
	i = list(
		id = id,
		uri = uri
	)

	i$get_item_metadata = function(uri) {
		res <- api_request(uri)
		return(fromJSON(res))
	}

	i$get_item_primary_text = function(uri) {
		metadata <- get_item_metadata(uri)
		if(!is.null(metadata$primary_text_url) && metadata$primary_text_url != "No primary text found") {
			res <- api_request(metadata$primary_text_url)
			return(res)
		}
		else {
			return("")
		}
	}

	i$get_documents = function() {
		metadata <- get_item_metadata(uri)
		return(metadata$documents)
	}

	i$get_document = function(index) {
		metadata <- get_item_metadata(uri)
		doc <- metadata$documents[index]
		return(Document(doc$url))
	}

	i$get_annotations = function(type = NULL, label = NULL) {
		# TODO: get annotations
	}

	i <- list2env(i)
    class(i) <- "ItemClass"
    return(i)
}