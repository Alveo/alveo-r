Item <- setRefClass("Item",

	fields = list(
		id = "character",
		uri = "character"
	),

	methods = list(

		get_metadata = function() {
			res <- api_request(uri)
			return(fromJSON(res))
		},

		get_primary_text = function() {
			metadata <- get_metadata()
			if(!is.null(metadata$primary_text_url) && metadata$primary_text_url != "No primary text found") {
				res <- api_request(metadata$primary_text_url)
				return(res)
			}
			else {
				return("")
			}
		},

		get_documents = function() {
			metadata <- get_metadata()
			return(metadata$documents)
		},

		get_document = function(index) {
			metadata <- get_metadata()
			doc <- metadata$documents[index]
			return(Document(uri=doc$url))
		},

		get_annotations = function(type = NULL, label = NULL) {
			# TODO: get annotations
		},

		show = function() {
			cat("ID: \n")
			methods::show(id)
			cat("URI: \n")
			methods::show(uri)
		}
	)
)