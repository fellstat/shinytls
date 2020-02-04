# Generate TLS Sample Frame

Once the population frame has been generated (using the __Generate Population Frame__ tab), and preliminary groundwork has been done visiting some of the venues and counting the number of population members present, the __Generate TLS Sample Frame__ tool is used to select the venues and times that are to be sampled.

In order to do this, the generator:

1. Constructs a statistical model for the popularity of venue/day/time combinations.
2. It uses the model to randomly select venue such that more popular venues have a larger probability of being selected.
3. Generates the a data frame showing what venues to visit and when.

Input:

- **Venue visit sample size -** The number of venue visits that will be conducted during the survey.
- **Survey Length -** The number of weeks the survey will be conducted over. Visits will be spread out evenly across weeks.
- **Maximum number of individuals sampled per visit -** For larger venues, it may not be desirable or cost effective to conduct the survey on every single eligible individual. This parameter is the number of individuals that will be sampled at these larger venues.
- **Stratify by ... -** This allows the user to stratify selection such that each strata has the same number of venue/day/time combinations.

Output:

- **Sample Frame -** A subset of the population frame detailing the venue visit locations and times.
- **Diagnostics -** Details about the fitted mathematical model for popularity.

------
**Mathematical Details:**

The probability that a venue/day/time combination will be selected for sampling is determined as follows. First, a statistical model is built predicting the number of individuals from the population that are present. The model is formulated as a hierarchical Poisson mixed model taking into account the venue, venue type, day of week and time of day. The exact formulation of this model is selected by optimizing the AIC value. For each possibility, the predicted value of this model (q_i) is calculated, and then the sample is chosen by drawing with replacement and using probabilities proportional to:

q_i = q_i / min(m, q_i)

where, m is the maximum number of individuals that will be sampled at a venue visit. So, if the venues all have size greater than m, sampling is proportional to venue size. This weighting scheme is designed to be approximately self balancing.

-------
