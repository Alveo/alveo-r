require(testthat)
require(alveo)

context("Client Tests")

test_that("Can read the configuration file", {
	
	config <- read_config()
	
	expect_that(config$apiKey, is_a("character"))
	expect_that(config$base_url, matches("http.*"))
	expect_that(api_key(), is_a("character"))
	expect_that(cache_dir(), is_a("character")) # maybe also that it names a real directory?
	
})

test_that("Can connect to a server", {
	
	config <- read_config()
	
	client <- RestClient(config$base_url)
	
	# we get some kind of string back from the server
	expect_that(client$get_api_version() == "", is_false())
	
	})

test_that("Can decode annotation context", {
	
	config <- read_config()
	client <- RestClient(config$base_url)
	
	context <- client$get_annotation_context()
	expect_that(context$`@context`$rdf$`@id`, equals("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
})

test_that("Can get item lists", {
	
	config <- read_config()
	client <- RestClient(config$base_url)
	
    item_lists <- client$get_item_lists()

    expect_that(mode(item_lists$own), equals("list"))
    expect_that(mode(item_lists$shared), equals("list"))
    
    expect_that(mode(item_lists$own[[1]]$name), equals("character"))
    expect_that(item_lists$own[[1]]$item_list_url, matches("http*"))
    
    
    
})


test_that("Can get an item list", {
	
	config <- read_config()
	client <- RestClient(config$base_url)
	
    item_lists <- client$get_item_lists()
    
    url <- item_lists$own[[1]]$item_list_url
    item_list <- client$get_item_list(url)
        
    expect_that(item_list$uri, equals(url))
    expect_that(item_list$items[1], matches("http*"))
})


test_that("Can get an item", {
	
	config <- read_config()
	client <- RestClient(config$base_url)
	
    item_lists <- client$get_item_lists()
    
    url <- item_lists$own[[1]]$item_list_url
    item_list <- client$get_item_list(url)
    
    item <- client$get_item(item_list$items[1])
        
    expect_that(item$uri, equals(item_list$items[1]))
    
    
})

test_that("Can get a document from an item", {
    
    emptyCache()
	
	config <- read_config()
	client <- RestClient(config$base_url)
	
    item_lists <- client$get_item_lists()
    
    url <- item_lists$own[[1]]$item_list_url
    item_list <- client$get_item_list(url)
    
    item <- client$get_item(item_list$items[1])
            
    doc <- item$get_document(1)
    
    expect_that(class(doc)[1], equals("Document"))

    expect_that(doc$type, equals("Text"))

    local <- doc$download()
    
    # local file extension should be same as on uri
    expect_that(file_ext(local), equals("txt"))
    
    # local file should be there
    expect_that(file.exists(local), is_true())
    
      
})


test_that("Can get a txt document", {
	
    emptyCache()
	config <- read_config()
	client <- RestClient(config$base_url)
	
    txturi <- paste(config$base_url, "catalog/cooee/2-334/document/2-334-plain.txt", sep="")
    
    txtdoc <- Document(uri=txturi)
    local <- txtdoc$download()
    
    # local file extension should be same as on uri
    expect_that(file_ext(local), equals("txt"))
    
    # local file should be there
    expect_that(file.exists(local), is_true())
    
    # check file size
    expect_that(file.info(local)$size, equals(2220))
    
    # doing it again should use the cache
    local2 <- txtdoc$download()
    expect_that(local2, equals(local))
    
    # look at the content
    text <- txtdoc$get_content()
    expect_that(text, matches("At all periods during"))      

})


test_that("Can get a wav document", {
	
    emptyCache()
	config <- read_config()
	client <- RestClient(config$base_url)
	
    wavuri <- paste(config$base_url, "catalog/rirusyd/Lecture_Theatre2_44deg/document/Lecture_Theatre2_44deg.wav", sep="")
    
    wavdoc <- Document(uri=wavuri)
    local <- wavdoc$download()
        
    # local file extension should be same as on uri
    expect_that(file_ext(local), equals("wav"))
    
    # local file should be there
    expect_that(file.exists(local), is_true())
    
    # check file size
    expect_that(file.info(local)$size, equals(384096))
    
    # doing it again should use the cache
    local2 <- wavdoc$download()
    expect_that(local2, equals(local))

})



