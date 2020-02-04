# Generate Population Frame

This tool translates a dataset containing venue information from wide to long format. The venue information should be a comprehensive listing of congregation points for the population accessible to the researchers. The data should have columns for

- **Venue name -** A unique identifier for the venue.
- **Venue type -** A column for the venue type. For example, "Bar" or "Cafe." This is optional.
- **Days of the week venue is open -** This column contains the days of the week the venue is open separated by a space. Additionally, you can specify "Monday Tuesday Wednesday" as "Monday-Wednesday"
- "Times venue is open -" The time periods the venue is open. For many studies, time may be broken up into "Morning" "Day," "Evening," and "Night." However, any categorization is allowed.

The generated frame will be in long format, with one row for every day/time a venue is open. A blank column is added "subject_count." An initial survey of venues should collect the number of individuals in the target population at a subset of the possible venue/day/time combinations and record these values in the "subject_count" column, which will be used in the **Generate TLS Sample Frame** tab.
