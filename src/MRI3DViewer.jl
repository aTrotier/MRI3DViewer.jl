module MRI3DViewer

export MRIView
using NIfTI
using GLMakie
Makie.inline!(false)

# Write your package code here.
function MRIView(ni::NIVolume)
    MRIView(ni.raw,pixdim = ni.header.pixdim[2:4])
end

function MRIView(MRIArray::Array{T,4};pixdim = (1,1,1)) where T<:Real
    MRIArray = abs.(MRIArray)

    maxi = maximum(MRIArray)
    mini = minimum(MRIArray)
    sz = size(MRIArray,3)
    st = size(MRIArray,4)
    aspectRatio = pixdim[1]/pixdim[2]

    im_obs = Observable{Any}(copy(MRIArray))

    ##
    fig=Figure()
    ax = Axis(fig[1,1])

     # define  Slider for slice / time
     sg = SliderGrid(fig[2, 1],
     (label = "Slice", range = 1:1:sz, startvalue = ceil(Int32,sz/2),linewidth=30),
     (label = "Time", range = 1:1:st,  startvalue = 1,linewidth=30))

    # define vertical slider for contrast
    rs_h = IntervalSlider(fig[1, 2], range = LinRange(mini, maxi, 10000), startvalues = (mini, maxi),linewidth=30, horizontal = false)
    labeltext1 = lift(rs_h.interval) do int
    string(round.(int, digits = 2))
    end
    Label(fig[1, 3], labeltext1, tellheight = false, rotation = pi/2)


    # define menu for colormap / Orientation
    menu = Menu(fig, options = ["greys", "plasma", "cividis"], default = "greys")
    menu2 = Menu(fig, options = ["xy", "xz", "yz"], default = "xy")

    fig[1, 4] = vgrid!(
    Label(fig, "Colormap", width = nothing),
    menu,
    Label(fig, "Orientation", width = nothing),
    menu2,
    tellheight = false, width = 300)

    h1 = heatmap!(ax,abs.(im_obs[][:,:,sg.sliders[1].value[],sg.sliders[2].value[]]),colormap="greys",colorrange=(mini,maxi))
    hidedecorations!(ax)
    ax.aspect=aspectRatio

    # reorient image
    on(menu2.selection) do orient
        if orient == "xy"
            im_obs[] = copy(MRIArray)
            aspectRatio = pixdim[1]/pixdim[2]
        elseif orient == "xz"
            im_obs[] = permutedims(MRIArray,(1,3,2,4))
            aspectRatio = pixdim[1]/pixdim[3]
        elseif orient == "yz"
            im_obs[] = permutedims(MRIArray,(2,3,1,4))
            aspectRatio = pixdim[2]/pixdim[3]
        end
        sz = size(im_obs[],3)
        sg.sliders[1].range[]=1:1:sz
        sg.sliders[1].startvalue[] = ceil(Int32,sz/2)
        sg.sliders[1].value[] = ceil(Int32,sz/2)
    end

    onany(sg.sliders[1].value,sg.sliders[2].value,rs_h.interval,menu.selection,im_obs)  do o1,o2,o3,o4,im_obs
        h1 = heatmap!(ax,abs.(im_obs[:,:,o1,o2]),colormap=o4,colorrange=(o3[1],o3[2]))
        hidedecorations!(ax)
        ax.aspect=aspectRatio
    end
    fig
end # function MRIView

end # module
