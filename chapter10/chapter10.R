# Chapter 10: Vectorized Code and Performance Comparisons

# Function to compute absolute values using a for loop (non-vectorized)
abs_loop <- function(vec) {
  for (i in seq_along(vec)) {
    if (vec[i] < 0) {
      vec[i] <- -vec[i]
    }
  }
  vec
}

# Function to compute absolute values using logical indexing (vectorized)
abs_sets <- function(vec) {
  negs <- vec < 0
  vec[negs] <- -vec[negs]
  vec
}

# Compare execution time on a large vector to demonstrate speedup
long <- rep(c(-1, 1), 5e6)
system.time(abs_loop(long))
system.time(abs_sets(long))

# Built-in abs() function for performance comparison
system.time(abs(long))

# Examples of logical indexing in R
vec <- c(1, -2, 3, -4, 5, -6, 7, -8, 9, -10)
negatives <- vec < 0         # Identify negative entries
neg_values <- vec[negatives] # Extract negative values
neg_values * -1              # Multiply negatives by -1

# -------------------------------------------------------------------------
# Exercise: Replace symbol codes with descriptive names

# Loop-based replacement (slow approach)
change_symbols <- function(vec) {
  for (i in seq_along(vec)) {
    if (vec[i] == "DD") {
      vec[i] <- "joker"
    } else if (vec[i] == "C") {
      vec[i] <- "ace"
    } else if (vec[i] == "7") {
      vec[i] <- "king"
    } else if (vec[i] == "B") {
      vec[i] <- "queen"
    } else if (vec[i] == "BB") {
      vec[i] <- "jack"
    } else if (vec[i] == "BBB") {
      vec[i] <- "ten"
    } else {
      vec[i] <- "nine"
    }
  }
  vec
}

# Test the loop-based function
symbols <- c("DD", "C", "7", "B", "BB", "BBB", "0")
change_symbols(symbols)

# Performance test on a repeated vector
many <- rep(symbols, 1e6)
system.time(change_symbols(many))

# Vectorized replacement using logical indexing
change_vec <- function(vec) {
  vec[vec == "DD"] <- "joker"
  vec[vec == "C"]  <- "ace"
  vec[vec == "7"]  <- "king"
  vec[vec == "B"]  <- "queen"
  vec[vec == "BB"] <- "jack"
  vec[vec == "BBB"]<- "ten"
  vec[vec == "0"]  <- "nine"
  vec
}
system.time(change_vec(many))

# Vectorized replacement using a lookup table for maximum efficiency
change_vec2 <- function(vec) {
  lookup <- c("DD" = "joker", "C" = "ace", "7" = "king",
              "B" = "queen", "BB"= "jack", "BBB"= "ten", "0" = "nine")
  unname(lookup[vec])
}
system.time(change_vec2(many))

# -------------------------------------------------------------------------
# Fast loops and vectorization examples

# Loop to generate a sequence of numbers (pre-allocating vector vs not)
system.time({
  output <- vector("numeric", 1e6)
  for (i in seq_len(1e6)) {
    output[i] <- i + 1
  }
})

system.time({
  output <- NA
  for (i in seq_len(1e6)) {
    output[i] <- i + 1
  }
})

# -------------------------------------------------------------------------
# Slot machine simulation example

# Allocate vector to store simulation results
winnings <- numeric(1e6)

# Example of using a play() function to simulate a single play
# (Assumes play() is defined elsewhere)
for (i in seq_len(1e6)) {
  winnings[i] <- play()
}
mean(winnings)

# Measure time for simulation
system.time({
  for (i in seq_len(1e6)) {
    winnings[i] <- play()
  }
})

# Function to generate slot symbols for multiple plays
get_many_symbols <- function(n) {
  wheel <- c("DD", "7", "BBB", "BB", "B", "C", "0")
  symbols <- sample(
    wheel,
    size = 3 * n,
    replace = TRUE,
    prob = c(0.03, 0.03, 0.06, 0.10, 0.25, 0.01, 0.52)
  )
  matrix(symbols, ncol = 3)
}

# Test symbol generation
get_many_symbols(5)

# Function to simulate multiple plays and return a data frame of results
play_many <- function(n) {
  symb_mat <- get_many_symbols(n)
  data.frame(
    w1 = symb_mat[, 1],
    w2 = symb_mat[, 2],
    w3 = symb_mat[, 3],
    prize = score_many(symb_mat)
  )
}

# -------------------------------------------------------------------------
# Function to calculate prizes for slot machine combinations
score_many <- function(symbols) {
  # Base prize from cherries (C) and diamonds (DD)
  cherries <- rowSums(symbols == "C")
  diamonds <- rowSums(symbols == "DD")
  prize <- c(0, 2, 5)[cherries + diamonds + 1]
  prize[cherries == 0] <- 0  # No prize if there are no real cherries
  
  # Three of a kind prize overrides
  same <- symbols[,1] == symbols[,2] & symbols[,2] == symbols[,3]
  payoffs <- c("DD" = 100, "7" = 80, "BBB" = 40, "BB" = 25, "B" = 10, "C" = 10, "0" = 0)
  prize[same] <- payoffs[symbols[same, 1]]
  
  # All bars combination (excluding three of a kind)
  bars <- symbols %in% c("B", "BB", "BBB")
  all_bars <- apply(bars, 1, all) & !same
  prize[all_bars] <- 5
  
  # Wild diamond handling: two diamonds
  two_wilds <- diamonds == 2
  one <- two_wilds & symbols[,1] != symbols[,2] & symbols[,2] == symbols[,3]
  two <- two_wilds & symbols[,1] != symbols[,2] & symbols[,1] == symbols[,3]
  three <- two_wilds & symbols[,1] == symbols[,2] & symbols[,2] != symbols[,3]
  prize[one]   <- payoffs[symbols[one, 1]]
  prize[two]   <- payoffs[symbols[two, 2]]
  prize[three] <- payoffs[symbols[three, 3]]
  
  # Wild diamond handling: one diamond
  one_wild <- diamonds == 1
  wild_bars <- one_wild & rowSums(bars) == 2
  prize[wild_bars] <- 5
  one <- one_wild & symbols[,1] == symbols[,2]
  two <- one_wild & symbols[,2] == symbols[,3]
  three <- one_wild & symbols[,3] == symbols[,1]
  prize[one]   <- payoffs[symbols[one, 1]]
  prize[two]   <- payoffs[symbols[two, 2]]
  prize[three] <- payoffs[symbols[three, 3]]
  
  # Double prize for each diamond in the combination
  prize * 2^diamonds
}

# Performance test for large simulation
system.time(play_many(1e7))
