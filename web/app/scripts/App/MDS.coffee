# global define
# global Modernizr
# global numeric

define([
], (
) ->
    'use strict'
    class MDS
        # given a matrix of distances between some points, returns the
        # point coordinates that best approximate the distances
        @classic: (distances, dimensions) ->
            dimensions = dimensions or 2
            
            # square distances
            M = numeric.mul(-.5, numeric.pow(distances, 2))
            
            # double centre the rows/columns
            mean = (A) ->
                numeric.div numeric.add.apply(null, A), A.length
                
            rowMeans = mean(M)
            colMeans = mean(numeric.transpose(M))
            totalMean = mean(rowMeans)
            i = 0

            while i < M.length
                j = 0
                
                while j < M[0].length
                    M[i][j] += totalMean - rowMeans[i] - colMeans[j]
                    ++j
                ++i
  
            # take the SVD of the double centred matrix, and return the
            # points from it
            ret = numeric.svd(M)
            eigenValues = numeric.sqrt(ret.S)
            ret.U.map (row) ->
                numeric.mul(row, eigenValues).splice 0, dimensions
            
    return MDS
)