# Time Location Sampling Tool

Time location sampling (TLS) is an important tool for surveying populations that attend venues. It is particularly useful in populations (such as injection drug users and men who have sex with men) that are difficult to reach via other methods.

The implementation of a TLS survey generally proceeds in three phases:

1. **Venue Identification -** A list of venues frequented by the population is compiled, along with the days of the week and times that the venue is open. The __Generate Population Frame__ tab translates this list into a population sampling frame.
2. **Venue Popularity Study -** The study staff then visits venues at a variety of times and days of the week. The number of individuals in the study population is recorded and entered into the population sampling frame dataset. This dataset is then used by the __Generate TLS Sample Frame__ tab to determine which venues to visit and at what times.
3. **Analysis -** Like any non-trivial survey, weights must be added to the data in order to adjust for the sampling design. The __Calculate TLS Weights__ tab generates these weights. Additionally, replication weights are provided in order to facilitate the generation of confidence intervals and hypothesis tests. Given these weights, the analysis can be conducted in any standard statistical package (e.g. R, Stata).
 
