# Calculate TLS Weights

Like any non-trivial survey, weights must be added to the data in order to adjust for the sampling design. The __Calculate TLS Weights__ tab generates these weights. Additionally, replication weights are provided in order to facilitate the generation of confidence intervals and hypothesis tests. Given these weights, the analysis can be conducted in any standard statistical package (e.g. R, Stata).

Input:

- **CSV File -** The csv file should have one row per subject surveyed.
- **Venue/time sampling probability -** This is the column output by the __Generate TLS Sample Frame__ tab.
- **Sampling strata -** The sampling strata variable output by the __Generate TLS Sample Frame__. If no variable is selected, the calculation of the bootstrap replicate weights will assume no stratification.
- **Venue -** The venue the individual was sampled.
- **Day of week -** The day of the week that the individual was sampled.
- **Time -** The time of day the individual was sampled.
- **# of individuals observed -** The number of individuals from the population observed at the venue visit.

The above columns should have no missing values.

- **Number of bootstrap replicate weights -** The number of replicated to generate. These can be used in most standard statistical packages to perform inference.

Output:

- **Sample Weights -** this is the input dataset augmented with additional columns for the weights to be used in the analysis (analysis_weights), and the replicate weights (rep_weights_*).

-----------
Mathematical Details:

If q_i is the probability that the ith venue/day/time combination was selected by the **Generate TLS Sample Frame** tab, n_i is the number of individuals surveyed, and N_i is the number of population members observed, then the weight for a venue/day/time combination is

w_i = N_i / (q_i * n_i)

The replicate weights are generated using the Canty and Davison (1999) bootstrap.

```
Canty AJ, Davison AC. (1999) Resampling-based variance estimation for labour force surveys. The Statistician 48:379-391
```

----------

