# Chapter 6
# Writing Deal Function
deal <- function(cards) {
  cards[1, ]
}

deal(deck)

# Environment
install.packages("devtools")
install.packages("parenvs")
library(devtools)
library(parenvs)

parenvs(all = TRUE)

# Working With Environments
as.environment("package:stats")

# Three environment comes with their own accessor functions
globalenv()
baseenv()
emptyenv()

# Looking up environment's parent
parent.env(globalenv())
parent.env(emptyenv())
ls(emptyenv())
ls(globalenv())

# Using R’s $ syntax to access an object in a specific environment
head(globalenv()$deck, 3)

# Using assign function to save an object into a particular function
assign("new", "Hello Global", envir = globalenv())
globalenv()$new

# Assignment
new
new <- "Hello Active"
new

# Creates a quandry for R whenever R runs a function
roll <- function() {
  die <- 1:6
  dice <- sample(die, size = 2, replace = TRUE)
  sum(dice)
}

# Evaluation
show_env <- function(){
  list(ran.in = environment(),
       parent = parent.env(environment()),
       objects = ls.str(environment()))
}

# Result will tell the name of the Run time environment
show_env()

environment(show_env)
environment(parenvs)

show_env <- function(){
  a <- 1
  b <- 2
  c <- 3
  list(ran.in = environment(),
       parent = parent.env(environment()),
       objects = ls.str(environment()))
}

# This time when we run show_env, R stores a, b, and c in the run time environment:
show_env()

# R will also put a second type of object in a run time environment. if a function has arguments, R will copy over each argument to the runtime environment.
foo <- "take me to your runtime"
show_env <- function(x = foo){
  list(ran.in = environment(),
       parent = parent.env(environment()),
       objects = ls.str(environment()))
}
show_env()

# Warm up questions
deal <- function() {
  deck[1, ]
}

# Exercise
environment(deal)

# When deal calls deck, R will need to look up the deck object
deal()

# Removing the top card
DECK <- deck
deck <- deck[-1, ]
head(deck, 3)

# Adding code to deal
deal <- function() {
  card <- deck[1, ]
  deck <- deck[-1, ]
  card
}

# Exercise: rewrite the deck <- deck[-1, ] line of deal to assign deck[-1, ] to an object named
# Deck in the global environment.

deal <- function() {
  card <- deck[1, ]
  assign("deck", deck[-1, ], envir = globalenv())
  card
}

# Now deal will finally clean up the global copy of deck
deal()

shuffle <- function(cards) {
  random <- sample(1:52, size = 52)
  cards[random, ]
}

head(deck, 3)

a <- shuffle(deck)
head(deck, 3)
head(a, 3)

# Exercise: Rewrite shuffle so that it replaces the copy of deck that lives in the global environment with a shuffled version of DECK, the intact copy of deck that also lives in the global environment.

shuffle <- function(){
  random <- sample(1:52, size = 52)
  assign("deck", DECK[random, ], envir = globalenv())
}

# Closures
shuffle()
deal()

# Creating a function that takes deck as an argument and saves a copy of deck as DECK
setup <- function(deck) {
  DECK <- deck
  DEAL <- function() {
    card <- deck[1, ]
    assign("deck", deck[-1, ], envir = globalenv())
    card
  }
  SHUFFLE <- function(){
    random <- sample(1:52, size = 52)
    assign("deck", DECK[random, ], envir = globalenv())
  }
}

# Returning DEAL and SHUFFLE
setup <- function(deck) {
  DECK <- deck
  DEAL <- function() {
    card <- deck[1, ]
    assign("deck", deck[-1, ], envir = globalenv())
    card
  }
  SHUFFLE <- function(){
    random <- sample(1:52, size = 52)
    assign("deck", DECK[random, ], envir = globalenv())
  }
  list(deal = DEAL, shuffle = SHUFFLE)
}

deal <- cards$deal
shuffle <- cards$shuffle

deal
shuffle

environment(deal)
environment(shuffle)

# Instead of having each function reference the global environment to update deck, we can have them reference their parent environment at runtime

setup <- function(deck) {
  DECK <- deck
  DEAL <- function() {
    card <- deck[1, ]
    assign("deck", deck[-1, ], envir = parent.env(environment()))
    card
  }
  SHUFFLE <- function(){
    random <- sample(1:52, size = 52)
    assign("deck", DECK[random, ], envir = parent.env(environment()))
  }
  list(deal = DEAL, shuffle = SHUFFLE)
}
cards <- setup(deck)
deal <- cards$deal
shuffle <- cards$shuffle

# Final game
rm(deck)
shuffle()
deal()
