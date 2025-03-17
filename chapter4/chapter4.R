# Chapter 4

# Selecting Values
deck[ , ]

# Positive Integers
head(deck)
deck[1, 1]

deck[1, c(1, 2, 3)]

new <- deck[1, c(1, 2, 3)]
new

# Repetition
deck[c(1, 1), c(1, 2, 3)]

# Vectors in R

vec <- c(6, 1, 3, 6, 10, 5)
vec[1:3]

# Learning to use drop = FALSE
deck[1:2, 1:2]
deck[1:2, 1]
deck[1:2, 1, drop = FALSE]

# Negative Integers
deck[-(2:52), (1:3)]
deck[0, 0]

# Blank Spaces
deck[1, ]

# Logical Values
deck[1, c(TRUE, TRUE, FALSE)]

rows <- c(TRUE, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F,
          F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F,
          F, F, F, F, F, F, F, F, F, F, F, F, F, F)
deck[rows, ]

# Names
deck[1, c("face", "suit", "value")]
deck[ , "value"]

# Exercise-1 Complete the code to make a function that returns the first row of a data frame: 
deal <- function(cards) {
  cards[1. ]
}

deal(deck)

# Shuffle the deck
# Call the deck first
deck2 <- deck[1:52, ]
head(deck2)

# exact the deck in different order
deck3 <- deck[c(2, 1, 3:52), ]
head(deck3)

# Generaing random for shuffling the order of the cards in a deck
random <- sample(1:52, size = 52)
random

deck4 <- deck[random, ]
head(deck4)

# Exercise-2 Use th preceding ideas to write a shuffle function. 
# shuffle should take a data frame and return a shuffled copy of the data frame.
shuffle <- function(cards) {
  random <- sample(1:52, size = 52)
  cards[random, ]
}

# Shuffling cards between each deal
deal(deck)
deck2 <- shuffle(deck)
deal(deck2)

# Dollar Sign and Double Brackets

deck$value

mean(deck$value)
median(deck$value)

lst <- list(numbers = c(1,2), logical = TRUE, strings = c("a", "b", "c"))
lst

# Subset it
lst[1]

# This will return an error because of type: list
sum(lst[1])

# Lists the number in the list
lst$numbers

# Sums the numbers in the list
sum(lst$numbers)

# Use two brackets if elements in the list don't have a name
lst[[1]]

# Single brackets and Double brackets
lst["numbers"]

lst[["numbers"]]
