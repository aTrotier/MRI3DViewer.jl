# MRI3DViewer

[![Build Status](https://github.com/aTrotier/MRI3DViewer.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/aTrotier/MRI3DViewer.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/aTrotier/MRI3DViewer.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/aTrotier/MRI3DViewer.jl)


# Example :

```julia
using MRI3DViewer

im2show = zeros(Float64,128,128,64,5)

for t=1:5
    for j=1:64
        im2show[j:j+32,j:j+32,j,t].=1.0*t
    end
end
MRIView(im2show)
```

# NOT WORKING
