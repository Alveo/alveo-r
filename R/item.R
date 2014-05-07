Item <- setRefClass("Item",

	fields = list(
		id = "character",
		uri = "character"
	),

	methods = list(

		##' Return the item with the given url. The URL is derived from an item list and has the form /catalog/{id}
		##' @title get_item_metadata
		##' @return item list metadata as json
		get_metadata = function() {
			res <- api_request(uri)
			return(rjson::fromJSON(res)$`alveo:metadata`)
		},

		get_all_metadata = function() {
			res <- api_request(uri)
			return(rjson::fromJSON(res))
		},

		##' Return the indexable text for an item if any as a string. The URL is an item URL of the form /catalog/{id}
		##' @title get_item_primary_text
		##' @return item primary text if exists
		get_indexable_text = function() {
			metadata <- get_all_metadata()
			if(!is.null(metadata$`alveo:primary_text_url`) && metadata$`alveo:primary_text_url` != "No primary text found") {
				res <- api_request(metadata$`alveo:primary_text_url`)
				return(res)
			}
			else {
				return("")
			}
		},

		get_documents = function() {
			metadata <- get_all_metadata()
			return(metadata$`alveo:documents`)
		},

		get_document = function(index) {
			metadata <- get_all_metadata()
			if(index > length(metadata$`alveo:documents`) || index < 1) {
				stop('index out of bounds')
			}
			doc <- metadata$`alveo:documents`[[index]]
			return(Document(uri=doc$`alveo:url`, type=as.character(doc$`dc:type`), size=as.character(doc$`alveo:size`)))
		},

		get_annotations = function(type = NULL, label = NULL) {
			annotations_url <- "/annotations"
			if(!is.null(type) && !is.null(label)) {
				annotations_url <- paste(annotations_url, "?type=", type, "&label=", label, sep="")
			}
			else if(!is.null(type) && is.null(label)) {
				annotations_url <- paste(annotations_url, "?type=", type, sep="")
			}
			else if(is.null(type) && !is.null(label)) {
				annotations_url <- paste(annotations_url, "?label=", label, sep="")
			}

			res <- api_request(paste(uri, annotations_url, sep=""))
			return(rjson::fromJSON(res))
		},

		show = function() {
			cat("ID: \n")
			methods::show(id)
			cat("URI: \n")
			methods::show(uri)
		}
	)
)