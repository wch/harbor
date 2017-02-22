context("basic functionality")
test_that("we can do something", {

  docker_pull(image="hello-world")
  expect_that(any(grepl("hello-world", as.data.frame(images())$repo, fixed=TRUE)), equals(TRUE))

  res <- docker_run(image = "hello-world", capture_text = TRUE)
  expect_that(any(grepl("Hello from Docker", attr(res, "output"), fixed=TRUE)), equals(TRUE))

})




