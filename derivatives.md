# High entropy function smoothing and derivative estimation

**Motivation:** I was trying to smooth out high-entropy time-series data, and I found that every smoothing method I was applying to my data couldn't get the main features of the graph to line up at the correct time.

**The Solution:** I ended up developing this smoothing algorithm based off the bootstrap method. By nature, the bootstrap method produces NA datapoints on the tails, so I also added in a basic smoothing based off localized averages to fill in the missing values.

**Disclaimer:** While this solution worked for my dataset, there is no guarantees it will work for yours. Typically, a polynomial regression or LOESS regression will suffice. There is also a bit of parameter tweaking needed that doesn't have a quantifiable optimal solution.

**Results:** 