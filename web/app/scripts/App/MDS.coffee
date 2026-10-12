class MDS
    # classical (Torgerson) MDS, which for euclidean distances is the
    # same as PCA: the centred data projected onto its principal axes.
    # Decomposes whichever is smaller, the d×d scatter matrix or the
    # n×n Gram matrix (the double-centred squared distances).
    #
    # returns { embedding, eigenvalues } with embedding being an array of
    # [x, y] positions and eigenvalues all non-zero eigenvalues, largest
    # first (the variance along each axis, times n)
    @classical: (vectors, components = 2) ->
        n = vectors.length
        d = vectors[0].length
        means = for k in [0...d]
            vectors.reduce(((sum, v) -> sum + v[k]), 0) / n
        centred = (v.map((value, k) -> value - means[k]) for v in vectors)

        if d <= n
            scatter = for a in [0...d]
                for b in [0...d]
                    centred.reduce(((sum, v) -> sum + v[a] * v[b]), 0)
            { values, vectors: axes } = MDS.__symmetricEigen(scatter)
            embedding = for v in centred
                for c in [0...components]
                    if c < d then v.reduce(((sum, value, k) -> sum + value * axes[k][c]), 0) else 0
        else
            gram = for i in [0...n]
                for j in [0...n]
                    centred[i].reduce(((sum, value, k) -> sum + value * centred[j][k]), 0)
            { values, vectors: axes } = MDS.__symmetricEigen(gram)
            embedding = for i in [0...n]
                for c in [0...components]
                    if values[c] > 0 then axes[i][c] * Math.sqrt(values[c]) else 0

        # the sign of each axis is arbitrary; flip it so that the point
        # furthest from the centre lies on the positive side
        for c in [0...components]
            largest = 0
            for position in embedding
                largest = position[c] if Math.abs(position[c]) > Math.abs(largest)
            if largest < 0
                for position in embedding
                    position[c] = -position[c]

        return {
            embedding: embedding
            eigenvalues: values.filter((value) -> value > 1e-12)
        }


    # eigen decomposition of a symmetric matrix with the cyclic Jacobi
    # method. Returns { values, vectors }, sorted by descending
    # eigenvalue, with vectors[i][k] the i-th entry of the k-th
    # eigenvector.
    @__symmetricEigen: (matrix, maxSweeps = 100) ->
        n = matrix.length
        A = (row.slice() for row in matrix)
        V = for i in [0...n]
            ((if i == j then 1 else 0) for j in [0...n])

        for sweep in [0...maxSweeps]
            offDiagonal = 0
            for i in [0...n]
                for j in [i+1...n]
                    offDiagonal += A[i][j] * A[i][j]
            break if offDiagonal < 1e-22

            for p in [0...n]
                for q in [p+1...n]
                    continue if Math.abs(A[p][q]) < 1e-300
                    theta = (A[q][q] - A[p][p]) / (2 * A[p][q])
                    t = (if theta >= 0 then 1 else -1) / (Math.abs(theta) + Math.sqrt(theta * theta + 1))
                    c = 1 / Math.sqrt(t * t + 1)
                    s = t * c

                    for k in [0...n]
                        akp = A[k][p]
                        akq = A[k][q]
                        A[k][p] = c * akp - s * akq
                        A[k][q] = s * akp + c * akq
                    for k in [0...n]
                        apk = A[p][k]
                        aqk = A[q][k]
                        A[p][k] = c * apk - s * aqk
                        A[q][k] = s * apk + c * aqk
                    for k in [0...n]
                        vkp = V[k][p]
                        vkq = V[k][q]
                        V[k][p] = c * vkp - s * vkq
                        V[k][q] = s * vkp + c * vkq

        order = [0...n].sort((a, b) -> A[b][b] - A[a][a])
        values = (A[k][k] for k in order)
        vectors = for i in [0...n]
            (V[i][k] for k in order)

        return { values, vectors }


    # SMACOF multidimensional scaling, a port of scikit-learn's
    # manifold.MDS (which the server used to run). Takes the raw
    # high-dimensional vectors, computes euclidean dissimilarities and
    # iteratively minimises the stress with the Guttman transform.
    #
    # options:
    #   metric      true (default) fits the actual distances,
    #               false fits only their rank order (Kruskal’s
    #               non-metric MDS, using isotonic regression)
    #   components  number of output dimensions (default 2)
    #   init        "classical" (default) starts once from the classical
    #               MDS solution, "random" uses nInit random starts, or
    #               an array of [x, y] starting positions
    #   nInit       number of random restarts, the best one wins (default 10)
    #   maxIter     maximum iterations per restart (default 3000)
    #   eps         convergence threshold (default 1e-6)
    #   seed        seed for the random starting positions (default 1)
    #
    # returns { embedding, stress } with embedding being an array of
    # [x, y] positions and stress the raw stress of the best run
    @smacof: (vectors, options = {}) ->
        metric = if options.metric? then options.metric else true
        components = options.components or 2
        nInit = options.nInit or 10
        maxIter = options.maxIter or 3000
        eps = if options.eps? then options.eps else 1e-6
        random = MDS.__random(if options.seed? then options.seed else 1)

        dissimilarities = MDS.__distanceMatrix(vectors)

        # starting from classical MDS reaches about the same stress as
        # the best of 10 random starts, in a fraction of the time
        init = options.init or "classical"
        if init == "classical"
            init = MDS.classical(vectors, components).embedding
        if Array.isArray(init)
            return MDS.__smacofSingle(dissimilarities, metric, components, maxIter, eps, random, init)

        best = null
        for run in [0...nInit]
            result = MDS.__smacofSingle(dissimilarities, metric, components, maxIter, eps, random)
            if not best or result.stress < best.stress
                best = result

        return best


    @__smacofSingle: (similarities, metric, components, maxIter, eps, random, init) ->
        n = similarities.length

        # given or random start positions in [0, 1)
        X = for i in [0...n]
            if init then init[i].slice() else (random() for c in [0...components])

        # the upper triangle of the dissimilarity matrix, used for the
        # isotonic regression in non-metric scaling
        if not metric
            pairs = []
            for i in [0...n]
                for j in [i+1...n]
                    if similarities[i][j] != 0
                        pairs.push([i, j])
            pairs.sort((a, b) -> similarities[a[0]][a[1]] - similarities[b[0]][b[1]])

        oldStress = null
        stress = 0
        iterations = 0
        for it in [0...maxIter]
            iterations = it + 1
            dis = MDS.__distanceMatrix(X)

            if metric
                disparities = similarities
            else
                disparities = MDS.__nonMetricDisparities(similarities, dis, pairs)

            stress = 0
            for i in [0...n]
                for j in [i+1...n]
                    d = dis[i][j] - disparities[i][j]
                    stress += d * d

            # Guttman transform: X = 1/n * B * X
            newX = for i in [0...n]
                (0 for c in [0...components])
            for i in [0...n]
                rowSum = 0
                for j in [0...n]
                    continue if i == j
                    ratio = disparities[i][j] / (if dis[i][j] == 0 then 1e-5 else dis[i][j])
                    rowSum += ratio
                    for c in [0...components]
                        newX[i][c] -= ratio * X[j][c]
                for c in [0...components]
                    newX[i][c] = (newX[i][c] + rowSum * X[i][c]) / n
            X = newX

            # convergence criterion as in scikit-learn (>= 1.7): the
            # decrease in stress relative to the sum of squared distances
            if oldStress != null
                sumSquaredDistances = 0
                for i in [0...n]
                    for j in [i+1...n]
                        sumSquaredDistances += dis[i][j] * dis[i][j]
                if (oldStress - stress) / sumSquaredDistances < eps
                    break
            oldStress = stress

        return {
            embedding: X
            stress: stress
            iterations: iterations
        }


    # Kruskal’s monotone regression: find disparities that preserve the
    # rank order of the dissimilarities while being as close as
    # possible to the current distances (pool adjacent violators)
    @__nonMetricDisparities: (similarities, dis, pairs) ->
        n = similarities.length

        # group tied dissimilarities, averaging their distances
        blocks = []
        for pair in pairs
            value = similarities[pair[0]][pair[1]]
            d = dis[pair[0]][pair[1]]
            last = blocks[blocks.length - 1]
            if last and last.value == value
                last.sum += d
                last.count += 1
            else
                blocks.push(
                    value: value
                    sum: d
                    count: 1
                )

        # pool adjacent violators
        pooled = []
        for block in blocks
            current =
                sum: block.sum
                count: block.count
                mean: block.sum / block.count
            while pooled.length and pooled[pooled.length - 1].mean > current.mean
                previous = pooled.pop()
                current.sum += previous.sum
                current.count += previous.count
                current.mean = current.sum / current.count
            pooled.push(current)

        # expand the fitted values back onto the pairs
        fitted = []
        for block in pooled
            for k in [0...block.count]
                fitted.push(block.mean)

        disparities = for i in [0...n]
            (0 for j in [0...n])
        sumSquares = 0
        for pair, index in pairs
            value = fitted[index]
            disparities[pair[0]][pair[1]] = value
            disparities[pair[1]][pair[0]] = value
            sumSquares += value * value

        # scale so that the disparities have the same overall size
        # as the distances they are compared to
        scale = Math.sqrt((n * (n - 1) / 2) / sumSquares)
        for i in [0...n]
            for j in [0...n]
                disparities[i][j] *= scale

        return disparities


    @__distanceMatrix: (vectors) ->
        n = vectors.length
        matrix = for i in [0...n]
            (0 for j in [0...n])
        for i in [0...n]
            for j in [i+1...n]
                sum = 0
                for v, k in vectors[i]
                    d = v - vectors[j][k]
                    sum += d * d
                matrix[i][j] = matrix[j][i] = Math.sqrt(sum)
        return matrix


    # small seeded random number generator (mulberry32) so that the same
    # data always results in the same projection
    @__random: (seed) ->
        state = seed >>> 0
        return ->
            state = (state + 0x6D2B79F5) >>> 0
            t = state
            t = Math.imul(t ^ (t >>> 15), t | 1)
            t ^= t + Math.imul(t ^ (t >>> 7), t | 61)
            ((t ^ (t >>> 14)) >>> 0) / 4294967296

        
export default MDS
