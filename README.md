# RDataAnalysis

This R project analyzes and models country-level data using both classification and clustering techniques. The goal is to predict and interpret death rate levels based on economic and demographic indicators.

## 📊 Data Sources

- [Countries and death causes](https://lms.uwa.edu.au/bbcswebdav/pid-3998436-dt-content-rid-47695412_1/courses/CITS4009_SEM-2_2024/Countries%20and%20death%20causes.csv)
- [World Bank: Population](https://data.worldbank.org/indicator/SP.POP.TOTL)
- [World Bank: GDP per capita](https://data.worldbank.org/indicator/NY.GDP.PCAP.CD)

## 🧠 Classification Methods

Three models were trained to classify whether a country's death rate is high or low:

- **Null Model** (baseline)
- **Decision Tree**
- **Logistic Regression**

**Evaluation metric:** AUC (Area Under the Curve)  
- Logistic Regression AUC (Test): 0.89  
- Decision Tree AUC (Test): lower than Logistic Regression

Feature importance was interpreted using **LIME**, identifying **GDP per capita** as more significant than **population**.

## 🔍 Clustering Analysis

Clustering was performed using **K-means** on numerical features:

- **Features:** `gdp.pcap`, `population`
- **Distance metric:** Euclidean
- **Cluster evaluation:**  
  - Calinski-Harabasz Index (best k=9)  
  - Average Silhouette Width (best k=2)  
  - Balanced choice: **k=3** chosen as optimal

## 📦 R Packages Used

- `rpart`, `rpart.plot` — for decision tree modeling
- `ROCR` — for AUC performance
- `lime` — for local model interpretation
- `flexclust`, `fpc`, `factoextra` — for clustering
- `ggplot2`, `dplyr` — for visualization and data wrangling

## 🛠 How to Run

1. Open the `.Rmd` or script file in RStudio.
2. Ensure required packages are installed.
3. Run each section sequentially or knit to HTML/PDF.

## 📺 Video Demonstration

Watch a detailed explanation of the project here:  
🔗 https://youtu.be/h-RnXlrg7k0?si=8PqhNFHcmpNfznCC

## 📅 Author

**Guoxing Zhu**  
Student Number: 24308319

## 📝 License

This project is for academic use and demonstration purposes.
