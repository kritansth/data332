# Chapter 9

# Using Loops In R

# Calculating Expected Values

die <- c(1, 2, 3, 4, 5, 6)
rolls <- expand.grid(die, die)
rolls

rolls$value <- rolls$Var1 + rolls$Var2
head(rolls, 3)

prob <- c("1" = 1/8, "2" = 1/8, "3" = 1/8, "4" = 1/8, "5" = 1/8, "6" = 3/8)
prob

rolls$prob1 <- prob[rolls$Var1]
head(rolls, 3)

rolls$prob2 <- prob[rolls$Var2]
head(rolls, 3)

rolls$prob <- rolls$prob1 * rolls$prob2
head(rolls, 3)

sum(rolls$value * rolls$prob)

# Practice Task With Symbol Combos

combos <- expand.grid(wheel, wheel, wheel, stringsAsFactors = FALSE)
combos

get_symbols <- function() {
  wheel <- c("DD", "7", "BBB", "BB", "B", "C", "0")
  sample(wheel, size = 3, replace = TRUE,
         prob = c(0.03, 0.03, 0.06, 0.1, 0.25, 0.01, 0.52))
}

# Define Probabilities For Each Symbol

prob <- c("DD" = 0.03, "7" = 0.03, "BBB" = 0.06,
          "BB" = 0.1, "B" = 0.25, "C" = 0.01, "0" = 0.52)

# Assign Symbol Probabilities To Combo Table

combos$prob1 <- prob[combos$Var1]
combos$prob2 <- prob[combos$Var2]
combos$prob3 <- prob[combos$Var3]
head(combos, 3)

# Multiply Probabilities Across All Three Slots

combos$prob <- combos$prob1 * combos$prob2 * combos$prob3
head(combos, 3)

sum(combos$prob)

symbols <- c(combos[1, 1], combos[1, 2], combos[1, 3])

score(symbols)

# Introduction To For Loops

for (value in that) {
  this
}

for (value in c("My", "first", "for", "loop")) {
  print("one run")
}

for (value in c("My", "second", "for", "loop")) {
  print(value)
}

value

for (word in c("My", "second", "for", "loop")) {
  print(word)
}
for (string in c("My", "second", "for", "loop")) {
  print(string)
}
for (i in c("My", "second", "for", "loop")) {
  print(i)
}

for (value in c("My", "third", "for", "loop")) {
  value
}

# Saving Loop Output To A Vector

chars <- vector(length = 4)

words <- c("My", "fourth", "for", "loop")
for (i in 1:4) {
  chars[i] <- words[i]
}
chars

# Add A Prize Column To Combos

combos$prize <- NA
head(combos, 3)

# Loop Through Combos To Calculate Prize

for (i in 1:nrow(combos)) {
  symbols <- c(combos[i, 1], combos[i, 2], combos[i, 3])
  combos$prize[i] <- score(symbols)
}

head(combos, 3)

sum(combos$prize * combos$prob)

# Challenge: Slot Scoring Function

score <- function(symbols) {
  diamonds <- sum(symbols == "DD")
  cherries <- sum(symbols == "C")
  # Check Matching Symbols Without Wilds
  slots <- symbols[symbols != "DD"]
  same <- length(unique(slots)) == 1
  bars <- slots %in% c("B", "BB", "BBB")
  # Assign Payout Based On Slot Match
  if (diamonds == 3) {
    prize <- 100
  } else if (same) {
    payouts <- c("7" = 80, "BBB" = 40, "BB" = 25,
                 "B" = 10, "C" = 10, "0" = 0)
    prize <- unname(payouts[slots[1]])
  } else if (all(bars)) {
    prize <- 5
  } else if (cherries > 0) {
    # Include Wilds With Cherries
    prize <- c(0, 2, 5)[cherries + diamonds + 1]
  } else {
    prize <- 0
  }
  # Double Prize For Every Diamond
  prize * 2^diamonds
}

# Recalculate Prizes Using New Score Logic

for (i in 1:nrow(combos)) {
  symbols <- c(combos[i, 1], combos[i, 2], combos[i, 3])
  combos$prize[i] <- score(symbols)
}

sum(combos$prize * combos$prob)

# While Loop Example: Play Until Broke

plays_till_broke <- function(start_with) {
  cash <- start_with
  n <- 0
  while (cash > 0) {
    cash <- cash - 1 + play()
    n <- n + 1
  }
  n
}
plays_till_broke(100)

# Repeat Loop Version: Same Idea As While

plays_till_broke <- function(start_with) {
  cash <- start_with
  n <- 0
  repeat {
    cash <- cash - 1 + play()
    n <- n + 1
    if (cash <= 0) {
      break
    }
  }
  n
}
plays_till_broke(100)