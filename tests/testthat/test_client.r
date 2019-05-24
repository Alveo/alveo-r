require(testthat)
require(alveo)
require(tools)
require(httptest)

context("Client Tests")

generate_identifier <- function() {
  return(paste(sample(c(letters[1:6],0:9),10,replace=TRUE), collapse=""))
}

test_that("Can read the configuration file", {

    config <- read_config()
  	
  	expect_that(config$apiKey, is_a("character"))
  	expect_match(config$base_url, "http.*")
  	expect_that(api_key(), is_a("character"))
})

test_that("Can connect to a server", {
  
  config <- read_config()
  
  with_mock_api({
    client <- RestClient(config$base_url)
      
    # we get some kind of string back from the server
    expect_that(client$get_api_version() == "", is_false())
  })
})

test_that("Can connect to the default server", {
  
  with_mock_api({
    client <- RestClient()
    
    # we get some kind of string back from the server
    expect_that(client$get_api_version() == "", is_false())
  })
})

test_that("Can decode annotation context", {
	
	config <- read_config()
	with_mock_api({
  	client <- RestClient(config$base_url)
  	
  	context <- client$get_annotation_context()
  	expect_that(context$`@context`$rdf$`@id`, equals("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
  })
})

test_that("Can get item lists", {
	
	config <- read_config()
	with_mock_api({
	  
	  client <- RestClient(config$base_url)
	
    item_lists <- client$get_item_lists()

    expect_that(mode(item_lists$own), equals("list"))
    expect_that(mode(item_lists$shared), equals("list"))
    
    expect_that(mode(item_lists$own[[1]]$name), equals("character"))
    expect_match(item_lists$own[[1]]$item_list_url, "http*")
	})
})


test_that("Can get an item list", {
	
	config <- read_config()
	with_mock_api({
	  
  	client <- RestClient(config$base_url)
	
    item_lists <- client$get_item_lists()
    
    url <- "https://app.alveo.edu.au/item_lists/1704"
    item_list <- client$get_item_list(url)
        
    expect_that(item_list$uri, equals(url))
    expect_match(item_list$items[1], "http*")
	})
})

test_that("Can create and delete an item list", {
  
  config <- read_config()
  with_mock_api({
    
    client <- RestClient(config$base_url)
    
    items <- NULL
    items$num_result <- 2
    items$items <- c("https://app.alveo.edu.au/catalog/mitcheldelbridge/S3819s1",
                     "https://app.alveo.edu.au/catalog/mitcheldelbridge/S2519s1")
    
    listname <- "alveo-R-test-list-zero"
    
    json <- client$create_item_list(items$items, listname)
    
    expect_that(json$success, equals(paste("2 items added to new item list ", listname, sep="")))
    
    listuri <- client$get_item_list_uri_by_name(listname)
    
    expect_that(substring(listuri, 0, 4), equals("http"))
    
    json <- client$delete_item_list(listuri)
    
    expect_that(json$success, equals(paste("item list '", listname, "' deleted successfully", sep="")))
  })
})


test_that("Can get documents from an item list", {
  
  config <- read_config()
  with_mock_api({
      
    client <- RestClient(config$base_url)
    
    url <- "https://app.alveo.edu.au/item_lists/1704"
    item_list <- client$get_item_list(url)
    
    documents <- item_list$get_item_documents()
    
    expect_that(length(documents), equals(4))
    
    # now just the audio files
    audiodocs <- item_list$get_item_documents(type="Audio")
    expect_that(length(audiodocs), equals(2))
    expect_that(audiodocs[[1]]$uri, equals("https://app.alveo.edu.au/catalog/mitcheldelbridge/S2375s1/document/S2375s1.wav"))
    
    
    # now audio and Textgrid
    alldocs <- item_list$get_item_documents(type=c("Audio", "TextGrid"))
    expect_that(length(alldocs), equals(4))
    expect_that(alldocs[[1]]$uri, equals("https://app.alveo.edu.au/catalog/mitcheldelbridge/S2375s1/document/S2375s1.wav"))
    expect_that(alldocs[[2]]$uri, equals("https://app.alveo.edu.au/catalog/mitcheldelbridge/S2375s1/document/S2375s1.TextGrid"))
    
    # now matching a pattern
    docs <- item_list$get_item_documents(pattern='S2375s1')
    expect_that(length(docs), equals(2))
    expect_that(alldocs[[1]]$uri, equals("https://app.alveo.edu.au/catalog/mitcheldelbridge/S2375s1/document/S2375s1.wav"))
    expect_that(alldocs[[2]]$uri, equals("https://app.alveo.edu.au/catalog/mitcheldelbridge/S2375s1/document/S2375s1.TextGrid"))
    
    # now matching a pattern at the end of the name
    docs <- item_list$get_item_documents(pattern='s1.wav')
    expect_that(length(docs), equals(2))
    expect_that(alldocs[[1]]$uri, equals("https://app.alveo.edu.au/catalog/mitcheldelbridge/S2375s1/document/S2375s1.wav"))
  })
})



test_that("Can create an item list from a query", {
	
	config <- read_config()
	with_mock_api({
  	  
  	client <- RestClient(config$base_url)
  	listname <- "alveo-R-test-list-two"
  	q = "collection_name:cooee AND created:1788 AND full_text:'Port Jackson'"
    items <- client$search_metadata(q)
    expect_type(items, "list")
    json <- client$create_item_list(items$items, listname)
  
    expect_that(json$success, 
                equals(paste(items$num_results, " items added to new item list ", listname, sep="")))
  
	})
})



test_that("Can get an item", {
	
	config <- read_config()
	with_mock_api({
	  
  	client <- RestClient(config$base_url)
    url <- "https://app.alveo.edu.au/catalog/mitcheldelbridge/S2375s1"
    item <- client$get_item(url)
    expect_that(item$uri, equals(url))
    
	})
})

test_that("Can get a document from an item", {
    
	  config <- read_config()
	  with_mock_api({
  	    
  	  client <- RestClient(config$base_url)
  	
      itemuri <- paste(config$base_url, "catalog/cooee/2-334", sep="")
      
      item <- client$get_item(itemuri)
              
      doc <- item$get_document(1)
      
      expect_that(class(doc)[1], equals("Document"))
  
      expect_that(doc$type, equals("Text"))
  
      local <- doc$download(destination='.')
      
      # local file extension should be same as on uri
      expect_that(file_ext(local), equals("txt"))
      
      # local file should be there
      expect_that(file.exists(local), is_true())
	  })
      
})


test_that("Can get a txt document", {
	
  	config <- read_config()
  	with_mock_api({
    	  
  	  client <- RestClient(config$base_url)
  	
      txturi <- paste(config$base_url, "catalog/cooee/2-334/document/2-334-plain.txt", sep="")
      
      txtdoc <- Document(uri=txturi)
      local <- txtdoc$download(destination='.')
      
      # local file extension should be same as on uri
      expect_that(file_ext(local), equals("txt"))
      
      # local file should be there
      expect_that(file.exists(local), is_true())
      
      # check file size
      expect_that(file.info(local)$size, equals(2220))
      
      # doing it again should use the cache
      local2 <- txtdoc$download(destination='.')
      expect_that(local2, equals(local))
      
      # look at the content
      text <- txtdoc$get_content()
      expect_match(text, "At all periods during")    
  })
})


test_that("Can get a wav document", {
	
  	config <- read_config()
  	with_mock_api({
    	  
  	  client <- RestClient(config$base_url)
  	
      wavuri <- paste(config$base_url, "catalog/rirusyd/lt22_44deg/document/lt22_44deg.wav", sep="")
      
      wavdoc <- Document(uri=wavuri)
      local <- wavdoc$download(destination='.', binary=TRUE)
          
      # local file extension should be same as on uri
      expect_that(file_ext(local), equals("wav"))
      
      # local file should be there
      expect_that(file.exists(local), is_true())
      
      # check file size
      expect_that(file.info(local)$size, equals(384096))
      
      # doing it again should use the cache
      local2 <- wavdoc$download(destination='.', binary=TRUE)
      expect_that(local2, equals(local))
  	})
})

test_that("can get a list of contributions", {
  
  config <- read_config()
  with_mock_api({
      
    client <- RestClient(config$base_url)
    contribs <- client$get_contributions()
    
    expect_that(mode(contribs$own), equals("list"))
    expect_that(mode(contribs$shared), equals("list"))
    
    expect_that(mode(contribs$own[[1]]$name), equals("character"))
    expect_match(contribs$own[[1]]$url, "http*")
  })
})

test_that("can I get details of a contribution", {
  
  config <- read_config()
  with_mock_api({
      
    client <- RestClient(config$base_url)
    contrib <- client$get_contribution('https://app.alveo.edu.au/contrib/6')
    
    expect_that(contrib$name, equals("Austalk Manual Transcriptions"))
    expect_that(length(contrib$documents), equals(180))
  })
})

test_that("Can run a SPARQL query", {
	
	config <- read_config()
	with_mock_api({
	    
	  client <- RestClient(config$base_url)
    collection <- "mitcheldelbridge"
    query <- "select * where { ?a ?b ?c } LIMIT 10"
	
    json <- client$sparql(query, collection)
    
    expect_that(json$head$vars, equals(c("a", "b", "c")))
    expect_that(length(json$results$bindings), equals(10))
	})
})



