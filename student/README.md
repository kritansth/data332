# Student Enrollment Analysis

This project analyzes student enrollment data, including majors, birth years, costs, and balance dues. The analysis is performed using R with the `readxl`, `dplyr`, and `ggplot2` libraries.

## Data Sources
- **Student Data**: Demographic information (`Student.xlsx`)
- **Registration Data**: Course registration records (`Registration.xlsx`)
- **Course Data**: Course details and financial information (`Course.xlsx`)

## Code Overview

### 1. Data Preparation
- Loads Excel files and merges datasets using `Student ID` and `Instance ID`.
- Converts `Birth Date` to a numeric `Birth Year` column.

### 2. Key Visualizations
1. **Students per Major**  
   Bar chart showing enrollment distribution across majors.  
   ![Plot 1 Example](https://via.placeholder.com/400x300/steelblue?text=Major+Distribution)

2. **Birth Year Distribution**  
   Histogram of student birth years (2-year bins).  
   ![Plot 2 Example](https://via.placeholder.com/400x300/darkgreen?text=Birth+Years)

3. **Cost Analysis**  
   Total cost per major, segmented by payment plan (stacked bars).  
   ![Plot 3 Example](https://via.placeholder.com/400x300/orange?text=Cost+by+Major)

4. **Balance Due Analysis**  
   Total balance due per major, segmented by payment plan.  
   ![Plot 4 Example](https://via.placeholder.com/400x300/red?text=Balance+Due)

### 3. Summary Statistics
- Aggregates total costs and balance dues by major/payment plan.

## How to Use
1. **Prerequisites**:  
   Install required packages:
   ```R
   install.packages(c("readxl", "dplyr", "ggplot2"))
