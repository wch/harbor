# Return a string of random letters and numbers, with an optional prefix.
random_name <- function(prefix = NULL, length = 6) {
  chars <- c(letters, 0:9)
  rand_str <- paste(sample(chars, length), collapse = "")
  paste(c(prefix, rand_str), collapse = "_")
}
