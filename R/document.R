Document <- function(uri) {
	d = list(
		uri = uri
	)

	d$get_content = function() {
		res <- api_request(uri)
		return(res)
	}

	d$download = function(destination) {
		content <- get_content(uri)

		if(!file.exists(destination)) {
			dir.create(destination)
		}

		basename <- basename(uri)
		filename <- file.path(destination, basename)

		write(content, file=filename)

		return(filename)
	}

	d <- list2env(d)
    class(d) <- "DocumentClass"
    return(d)
}