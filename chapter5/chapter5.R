# Chapter 5

deck2 <- deck

vec <- c(0, 0, 0, 0, 0, 0)
vec

vec[1]

# Assigning value of the vector
vec[1] <- 1000
vec

# Changing value of the vector
vec[c(1, 3, 5)] <- c(1, 1, 1)
vec

vec[4:6] <- vec[4:6] + 1
vec

# Create values that do not exist in the data set
vec[7] <- 0
vec

# Add new variable to the data set
deck2$new <- 1:52
head(deck2)

# Remove columns from data frame
deck2$new <- NULL
head(deck2)

# Changing the value of Aces to 14
# Extracting Aces
deck2[c(13, 26, 39, 52), ]

# Extracting Aces value only
deck2[c(13, 26, 39, 52), 3]
# Or
deck2$value[c(13, 26, 39, 52)]

# Changing Ace value to 14 
deck2$value[c(13, 26, 39, 52)] <- c(14, 14, 14, 14)
# OR
deck2$value[c(13, 26, 39, 52)] <- 14

head(deck2, 13)

deck3 <- shuffle(deck)
head(deck3)

# Logical Subsetting

vec
vec[c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)]

# Extract the face column of deck2 and test whether each value is equal to ace. 
deck2$face

deck2$face == "ace"
sum(deck2$face == "ace")
deck3$value[deck3$face == "ace"]
deck3$value[deck3$face == "ace"] <- 14
head(deck3)

# Hearts Game - each card has a value of zero except the suit of hearts

deck4 <- deck
deck4$value <- 0 
head(deck4, 13)

# Exercise assign a value of 1 to every card in deck4 that has a suit of hearts.
deck4$suit == "hearts"

deck4$value[deck4$suit == "hearts"] <- 1

deck4$value[deck4$suit == "hearts"]

# In this game Queen of spades has the most unusual value of 13 pts. 
deck4[deck4$face == "queen", ]
deck4[deck4$suit == "spades", ]

# Use of Boolean Expression
deck4$face == "queen" & deck4$suit == "spades"

queenOfSpades <- deck4$face == "queen" & deck4$suit == "spades"
deck4[queenOfSpades, ]

deck4$value[queenOfSpades]
deck4$value[queenOfSpades] <- 13
deck4[queenOfSpades, ]
# Deck now ready to play

# Exercise <- logical tests
w <- c(-1, 0, 1)
x <- c(5, 15)
y <- "February"
z <- c("Monday", "Tuesday", "Friday")

# Tests
# 1. Is w positive?
# 2. Is x greater than 10 and less than 20?
# 3. Is object y the word February?
# 4. Is every value in z a day of the week?

w > 0
10 < x & x < 20
y == "February"
all(z %in% c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday",
             "Saturday", "Sunday"))

# Black Jack Game
deck5 <- deck
head(deck5, 13)

# Change face card value all at once to 10
facecard <- deck5$face %in% c("king", "queen", "jack")
deck5[facecard, ]
deck5$value[facecard] <- 10
head(deck5, 13)

# Missing Information
NA == 1
c(NA, 1:50)
mean(c(NA, 1:50))

# Remove NA values
mean(c(NA, 1:50), na.rm = TRUE)

# is.na
NA == NA
c(1, 2, 3, NA) == NA
is.na(NA)

vec <- c(1, 2, 3, NA)
is.na(vec)
deck5$value[deck5$face == "ace"] <- NA
head(deck5, 13)
