##' A class representing a single item from the Alveo virtual lab
##' @field id The item identifier
##' @field uri The URI of the item 
##' @export Item
##' @exportClass Item
Item <- setRefClass("Item",

	fields = list(
		id = "character",
		uri = "character"
	),

	methods = list(
        
		get_metadata = function() {
            "Return the descriptive metadata for this item"
			res <- api_request(uri)
			return(rjson::fromJSON(res)$`alveo:metadata`)
		},

		get_all_metadata = function() {
            "Return full metadata for this item, including system properties"
			res <- api_request(uri)
			return(rjson::fromJSON(res))
		},

		get_indexable_text = function() {
            "Return the indexable text for this item if any"
			metadata <- get_all_metadata()
			if(!is.null(metadata$`alveo:primary_text_url`) && metadata$`alveo:primary_text_url` != "No primary text found") {
				res <- api_request(metadata$`alveo:primary_text_url`)
				return(res)
			}
			else {
				return("")
			}
		},

		get_documents = function(types=NULL, pattern=NULL) {
       "Return a list of all documents for this item
        If type is given, it should be a sequence of type names, return only documents
        of with dcterms:type in this sequence, eg. ('Audio', 'TextGrid').
        If pattern is given, return only documents with dcterms:identifier matching this regular expression"
      
        metadata <- get_all_metadata()
  			docs <- metadata$`alveo:documents`
        
        item_docs <- c()
  			for(j in 1:length(docs)) {
  			  if (is.null(types) || docs[[j]]$`dcterms:type` %in% types) {
  			    if (is.null(pattern) || regexpr(pattern, docs[[j]]$`dcterms:identifier`)==1 ) {
  			      d = Document(item=uri, uri=docs[[j]]$`alveo:url`, type=as.character(docs[[j]]$`dcterms:type`), size=as.character(docs[[j]]$`alveo:size`))
  			      item_docs <- c(item_docs, d)
  			    }
  			  }
  			}
        return(item_docs)
		},

		get_document = function(index) {
            "Return the document given by the (numerical) index, returns a Document object"
			metadata <- get_all_metadata()
			if(index > length(metadata$`alveo:documents`) || index < 1) {
				stop('index out of bounds')
			}
			doc <- metadata$`alveo:documents`[[index]]
			return(Document(item=uri, uri=doc$`alveo:url`, type=as.character(doc$`dcterms:type`), size=as.character(doc$`alveo:size`)))
		},

		get_annotations = function(type = NULL, label = NULL) {
            "Return all annotations on this document, the 'type' and 'label' arguments can be used to restrict the annotations returned."
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
			cat("ID:", id, "\n")
			cat("URI:", uri, "\n")
		}
	)
)