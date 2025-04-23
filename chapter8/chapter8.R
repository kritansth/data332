# Chapter 8

# Trying Out The S3 Class System
num <- 1000000000
print(num)

class(num) <- c("POSIXct", "POSIXt")
print(num)

# Exploring Object Attributes
attributes(deck)
row.names(deck)
levels(deck) <- c("Level 1", "Level 2", "Level 3")
attributes(deck)

# Simple Function Example

play <- function() {
  symbols <- get_symbols()
  print(symbols)
  score(symbols)
}

# Updated Version Of The Play Function

play <- function() {
  symbols <- get_symbols()
  prize <- score(symbols)
  attr(prize, "symbols") <- symbols
  prize
}

play()
two_play <- play()
two_play

# One-Step Attribute Assignment Using Structure()
play <- function() {
  symbols <- get_symbols()
  structure(score(symbols), symbols = symbols)
}
three_play <- play()
three_play

# Formatting Slot Machine Output

slot_display <- function(prize){
  # Pull Symbols From Prize Attribute
  symbols <- attr(prize, "symbols")
  # Combine Symbols Into A Single String
  symbols <- paste(symbols, collapse = " ")
  # Attach Symbols And Prize Value With A Line Break
  string <- paste(symbols, prize, sep = "\n$")
  # Print The Output Without Quotes
  cat(string)
}
slot_display(one_play)

# Exploring Generic Functions
print(pi)
pi
print(head(deck))
head(deck)

# Print Result Of Play Function
print(play())
play()

# Looking At Method Functions
print
print.POSIXct
print.factor

# Custom Print Method For Slot Results
print.slots <- function(x, ...) {
  slot_display(x)
}
one_play

# Assigning Class To Play Output

play <- function() {
  symbols <- get_symbols()
  structure(score(symbols), symbols = symbols, class = "slots")
}
class(play())
play()

# Listing Available Methods For A Specific Class

methods(class = "factor")

play1 <- play()
play1

play2 <- play()
play2

# Trying To Combine Multiple Plays

c(play1, play2)

# Indexing A Single Value From Play Output

play1[1]