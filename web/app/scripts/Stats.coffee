# The few statistics functions the app used from science.js, ported
# as they were so that the results stay the same. Unlike d3-array,
# they don’t skip null or NaN values.

mean = (x) ->
    n = x.length
    return NaN if n == 0
    m = 0
    for value, i in x
        m += (value - m) / (i + 1)
    return m


# R’s quantile algorithm type 7. Returns an array with one value per
# requested quantile.
quantiles = (d, qs) ->
    d = d.slice().sort((a, b) -> a - b)
    n_1 = d.length - 1
    values = for q in qs
        if q == 0
            d[0]
        else if q == 1
            d[n_1]
        else
            index = 1 + q * n_1
            lo = Math.floor(index)
            h = index - lo
            a = d[lo - 1]
            if h == 0 then a else a + h * (d[lo] - a)
    return values


# unbiased sample variance (denominator n - 1)
variance = (x) ->
    n = x.length
    return NaN if n < 1
    return 0 if n == 1
    m = mean(x)
    s = 0
    for value in x
        v = value - m
        s += v * v
    return s / (n - 1)


iqr = (x) ->
    [q1, q3] = quantiles(x, [0.25, 0.75])
    return q3 - q1


# Silverman’s rule of thumb, like R’s bw.nrd0
nrd0 = (x) ->
    hi = Math.sqrt(variance(x))
    lo = Math.min(hi, iqr(x) / 1.34)
    unless lo
        lo = hi or Math.abs(x[1]) or 1
    return 0.9 * lo * Math.pow(x.length, -0.2)


gaussian = (u) ->
    return 1 / Math.sqrt(2 * Math.PI) * Math.exp(-0.5 * u * u)


# gaussian kernel density estimate of sample, evaluated at points.
# Returns [x, density] pairs.
kde = (sample, points) ->
    bandwidth = nrd0(sample)
    n = sample.length
    density = for x in points
        y = 0
        for value in sample
            y += gaussian((x - value) / bandwidth)
        [x, y / bandwidth / n]
    return density


export default { mean, quantiles, variance, iqr, nrd0, kde }
