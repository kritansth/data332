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
   ![Number of Students per Major](https://github.com/kritansth/data332/raw/8fa7359d0fc8bcc7edab99bcf286a505a5b3c29c/student/n_students_per_major.png)

2. **Birth Year Distribution**  
   Histogram of student birth years (2-year bins).  
   ![Birth Year Distribution](https://github.com/kritansth/data332/raw/8fa7359d0fc8bcc7edab99bcf286a505a5b3c29c/student/dist_of_birth_years.png)


3. **Cost Analysis**  
   Total cost per major, segmented by payment plan (stacked bars).  
   ![Total Cost per Major](https://github.com/kritansth/data332/raw/8fa7359d0fc8bcc7edab99bcf286a505a5b3c29c/student/total_cost_per_major.png)

4. **Balance Due Analysis**  
   Total balance due per major, segmented by payment plan.  
   ![Balance Due per Major](https://github.com/kritansth/data332/raw/8fa7359d0fc8bcc7edab99bcf286a505a5b3c29c/student/total_balane_due_per_major.png)


### 3. Summary Statistics
- Aggregates total costs and balance dues by major/payment plan.

## How to Use
1. **Prerequisites**:  
   Install required packages:
   ```R
   install.packages(c("readxl", "dplyr", "ggplot2"))
