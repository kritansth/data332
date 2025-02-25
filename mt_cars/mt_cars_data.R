library(dplyr)

rm(list = ls())
data("mtcars")

head(mtcars)

str(mtcars)

#pivot

mtcars %>%
  summarise(count_of_car = n_distinct(rownames(mtcars)))

mtcars %>% group_by(cyl) %>% summarise(mean_weight = mean(wt))

mtcars %>% group_by(gear) %>% summarise(No_Of_Cars=n())

mtcars %>% group_by(gear) %>%
  summarise(Mean_MPG = mean(mpg))

mtcars %>% group_by(carb) %>%
  summarise(Mean_MPG = mean(mpg))

mtcars %>% group_by(cyl) %>%
  summarise(Mean_MPG = mean(mpg))

mtcars %>% group_by(gear,carb,cyl) %>%
  summarise(Mean_MPG = mean(mpg))
  
MAX_HP <- max(mtcars$hp)
print(paste("Maximum HP is", MAX_HP))
print(MAX_HP)
cat("Maximum HP is", MAX_HP)

mtcars %>% filter(hp==MAX_HP) %>%
  select(disp,gear,hp)

Min_DISP <- min(mtcars$disp)
mtcars %>% filter(disp==Min_DISP) %>%
  select(disp,gear,hp)

summary(mtcars)

#cyl_4_car <- filter(mtcars, cyl==4)
#cyl_4_car %>% select(cyl, disp, hp)
#use code below

cyl_4_car <- mtcars %>%
  dplyr::filter(cyl==4)
print(cyl_4_car)

#cyl_4_car <- cyl_4_car %>%
#  select(cyl, disp, hp)

cyl_4_car %>% filter(disp==max(cyl_4_car$disp)) %>%
  select(cyl,disp,hp)

cyl_4_car %>% filter(hp==min(cyl_4_car$hp)) %>%
  select(cyl,disp,hp)

gr_cl_4_car <- filter(mtcars,gear==4,cyl>=4) 
gr_cl_4_car %>% select(gear,cyl,hp,disp)

gr_cl_4_car %>% filter(disp==max(gr_cl_4_car$disp)) %>%
  select(gear,cyl,hp,disp)

gr_cl_4_car %>% filter(hp==min(gr_cl_4_car$hp)) %>%
  select(gear,cyl,hp,disp)

