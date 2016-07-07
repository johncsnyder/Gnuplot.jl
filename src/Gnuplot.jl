

__precompile__()

module Gnuplot

import Base.writemime



export plot, plot!, xlims!, ylims!, zlims!, write



type GnuplotHandle
    stdin
    stdout
    proc
end


function GnuplotHandle()
    stdout, stdin, proc = readandwrite(`gnuplot`)
    !Base.process_running(proc) && error("could not start gnuplot")
    GnuplotHandle(stdin,stdout,proc)
end




function __init__()
    global gnuplot = GnuplotHandle()
    global figures = Figure[]
    global logfile = tempname()
end


function send_string(s)
    global gnuplot, logfile
    open(logfile,"a") do io; write(io, s * "\n"); end
    w = write(gnuplot.stdin, s * "\n")
    @assert w > 0 "sending \"$s\" to gnuplot failed"
end

set_options(;kwargs...) = send_string(join(["set $(string(k)) \"$v\"" for (k,v) in kwargs], "\n"))
unset_options(args...) = send_string(join(["unset $(string(a))" for a in args], "\n"))

set_term(term) = send_string("set term $term")



function finish()
    finished = tempname()
    send_string("system(\"touch '$finished'\")")
    while !isfile(finished)
        sleep(0.001)
    end
end





abstract Data
abstract Data2D <: Data
abstract Data3D <: Data


colors = (:red, :blue, :green, :orange, :black, :grey, :magenta, :yellow, :purple)

write_data(data::Data) = return



typealias Tuple2{T} Tuple{T,T}
typealias Tuple4{T} Tuple{T,T,T,T}
typealias Tuple6{T} Tuple{T,T,T,T,T,T}
typealias Tuple8{T} Tuple{T,T,T,T,T,T,T,T}
typealias DashType Union{Symbol,Int,AbstractString,Tuple2{Int},Tuple4{Int},Tuple6{Int},Tuple8{Int}}



type DiscreteData2D <: Data2D
    x::AbstractVector
    y::AbstractVector
    label::AbstractString
    style::Symbol  # e.g. lines, dots, points, linespoints/lp, impulses, steps, fsteps, histeps, boxes, 
    linecolor::Union{Symbol,Int}  # :auto, 1, 2, :red, :blue
    linewidth::Union{Symbol,Int,Real}  # :auto, 1, 2, 3
    dashtype::DashType  # :auto, 1, :solid, "-._-.", (5,2), (5,3,1,2)
    pointtype::Union{Symbol,AbstractString,Int}  # :auto, 1, 
    pointsize::Union{Symbol,Int,Real}  # :auto, 1, 2, 3
    datafile::AbstractString
end


DiscreteData2D(x, y; label="", style=:auto, linecolor=:auto, linewidth=:auto,
    dashtype=:auto, pointtype=:auto, pointsize=:auto) = 
        DiscreteData2D(x, y, label, style, linecolor, linewidth, dashtype, pointtype, pointsize, "")



function write_data(data::DiscreteData2D)
    data.datafile = tempname() * ".dat"
    writedlm(data.datafile, [data.x data.y])
end






type DiscreteData3D <: Data3D
    x::AbstractVector
    y::AbstractVector
    z::AbstractVector
    label::AbstractString
    style::Symbol  # e.g. lines, dots, points, linespoints/lp, impulses, steps, fsteps, histeps, boxes, 
    linecolor::Union{Symbol,Int}  # :auto, 1, 2, :red, :blue
    linewidth::Union{Symbol,Int,Real}  # :auto, 1, 2, 3
    dashtype::DashType  # :auto, 1, :solid, "-._-.", (5,2), (5,3,1,2)
    pointtype::Union{Symbol,AbstractString,Int}  # :auto, 1, 
    pointsize::Union{Symbol,Int,Real}  # :auto, 1, 2, 3
    datafile::AbstractString
end


DiscreteData3D(x, y, z; label="", style=:auto, linecolor=:auto, linewidth=:auto,
    dashtype=:auto, pointtype=:auto, pointsize=:auto) = 
        DiscreteData3D(x, y, z, label, style, linecolor, linewidth, dashtype, pointtype, pointsize, "")




function write_data(data::DiscreteData3D)
    data.datafile = tempname() * ".dat"
    writedlm(data.datafile, [data.x data.y data.z])
end




function plot_string(data::Union{DiscreteData2D,DiscreteData3D})
    s = "\"$(data.datafile)\" title \"$(data.label)\""
    if data.style != :auto
        s *= " with $(string(data.style))"
    end
    if data.linecolor != :auto
        if data.linecolor in colors
            s *= " linecolor rgb \"$(string(data.linecolor))\""
        else
            s *= " linecolor $(string(data.linecolor))"
        end
    end
    if data.linewidth != :auto
        s *= " linewidth $(string(data.linewidth))"
    end
    if data.dashtype != :auto
        if isa(data.dashtype, AbstractString)
            s *= " dashtype \"$(data.dashtype)\""
        else
            s *= " dashtype $(string(data.dashtype))"
        end
    end
    if data.pointtype != :auto
        if isa(data.pointtype, AbstractString)
            s *= " pointtype \"$(data.pointtype)\""
        else
            s *= " pointtype $(string(data.pointtype))"
        end
    end
    if data.pointsize != :auto
        s *= " pointsize $(string(data.pointsize))"
    end
    s
end




type FunctionData2D{T} <: Data2D
    f::T
    label::AbstractString
    style::Symbol  # e.g. lines, dots, points, linespoints/lp, impulses, steps, fsteps, histeps, boxes, 
    linecolor::Union{Symbol,Int}  # :auto, 1, 2, :red, :blue
    linewidth::Union{Symbol,Int,Real}  # :auto, 1, 2, 3
    dashtype::DashType  # :auto, 1, :solid, "-._-.", (5,2), (5,3,1,2)
    pointtype::Union{Symbol,AbstractString,Int}  # :auto, 1, 
    pointsize::Union{Symbol,Int,Real}  # :auto, 1, 2, 3
    datafile::AbstractString
end


FunctionData2D(f; label="", style=:auto, linecolor=:auto, linewidth=:auto,
    dashtype=:auto, pointtype=:auto, pointsize=:auto) = 
        FunctionData2D(f, label, style, linecolor, linewidth, dashtype, pointtype, pointsize, "")



function plot_string(data::FunctionData2D)
    s = "\"$(data.datafile)\" title \"$(data.label)\""
    if data.style != :auto
        s *= " with $(string(data.style))"
    end
    if data.linecolor != :auto
        if data.linecolor in colors
            s *= " linecolor rgb \"$(string(data.linecolor))\""
        else
            s *= " linecolor $(string(data.linecolor))"
        end
    end
    if data.linewidth != :auto
        s *= " linewidth $(string(data.linewidth))"
    end
    if data.dashtype != :auto
        if isa(data.dashtype, AbstractString)
            s *= " dashtype \"$(data.dashtype)\""
        else
            s *= " dashtype $(string(data.dashtype))"
        end
    end
    if data.pointtype != :auto
        if isa(data.pointtype, AbstractString)
            s *= " pointtype \"$(data.pointtype)\""
        else
            s *= " pointtype $(string(data.pointtype))"
        end
    end
    if data.pointsize != :auto
        s *= " pointsize $(string(data.pointsize))"
    end
    s
end







abstract Figure




function write_data(fig::Figure)
    for (i,d) in enumerate(fig.data)
        write_data(d)
    end
end



type Figure2D <: Figure
    data::Vector{Data2D}
    title::AbstractString
    xlabel::AbstractString
    ylabel::AbstractString
    xlims::Union{Symbol,Tuple{Real,Real}}
    ylims::Union{Symbol,Tuple{Real,Real}}
    imgfile::AbstractString
end


Figure2D(data; title="", xlabel="", ylabel="", xlims=:auto, ylims=:auto) = Figure2D(data, title, xlabel, ylabel, xlims, ylims, "")
Figure2D() = Figure2D([])





plot_figure(fig::Figure2D) = send_string("plot " * join([plot_string(d) for d in fig.data], ","))


type Figure3D <: Figure
    data::Vector{Data3D}
    title::AbstractString
    xlabel::AbstractString
    ylabel::AbstractString
    xlims::Union{Symbol,Tuple{Real,Real}}
    ylims::Union{Symbol,Tuple{Real,Real}}
    zlims::Union{Symbol,Tuple{Real,Real}}
    imgfile::AbstractString
end


Figure3D(data; title="", xlabel="", ylabel="", xlims=:auto, ylims=:auto, zlims=:auto) = 
    Figure3D(data, title, xlabel, ylabel, xlims, ylims, zlims, "")
Figure3D() = Figure3D([])

plot_figure(fig::Figure3D) = send_string("splot " * join([plot_string(d) for d in fig.data], ","))



function discretize(f,xmin,xmax)
	x = collect(linspace(xmin, xmax, 10))

    # add jitter to avoid singularities ?
    for i in 2:length(x)-1
	    x[i] += 1e-6*(rand()-0.5)
	end

	y = [f(x[i]) for i in 1:length(x)]

	δymax = 1e-2*(maximum(y) - minimum(y))
	δxmin = 1e-4*(maximum(x) - minimum(x))
	δxmax = 1e-3*(maximum(x) - minimum(x))

	count = 0
	i = 1
	while i < length(y)
	    δx = x[i+1] - x[i]
	    δy = abs(y[i+1] - y[i])
	    if δx > δxmax || (δx > δxmin && δy > δymax)
	        xmid = (x[i+1] + x[i])/2.
	        insert!(x, i+1, xmid)
	        insert!(y, i+1, f(xmid))
	    else
	        i += 1
	    end
	    count += 1
	    @assert count < 100000
	end

	x,y
end


function plot()
    global figures
    fig = Figure2D()
    push!(figures, fig)
    fig
end




function plot(f,xmin,xmax;
        label="", style=:line, linecolor=:auto, linewidth=:auto,
        dashtype=:auto, pointtype=:auto, pointsize=:auto,
        title="", xlabel="", ylabel="", xlims=:auto, ylims=:auto)
    global figures
    x, y = discretize(f,xmin,xmax)
    data = DiscreteData2D(x, y; label=label, style=style, linecolor=linecolor,
        linewidth=linewidth, dashtype=dashtype, pointtype=pointtype, pointsize=pointsize)
    fig = Figure2D([data], title=title, xlabel=xlabel, ylabel=ylabel,
    	xlims=xlims, ylims=ylims)
    push!(figures, fig)
    fig
end




function plot!(f,xmin,xmax;
        label="", style=:line, linecolor=:auto, linewidth=:auto,
        dashtype=:auto, pointtype=:auto, pointsize=:auto,
        title="", xlabel="", ylabel="", xlims=:auto, ylims=:auto)
    global figures
    fig = figures[end]
    @assert isa(fig, Figure2D)
    x, y = discretize(f,xmin,xmax)
    data = DiscreteData2D(x, y; label=label, style=style, linecolor=linecolor,
        linewidth=linewidth, dashtype=dashtype, pointtype=pointtype, pointsize=pointsize)
    push!(fig.data, data)
    fig
end



plot(x::AbstractVector;
        label="", style=:line, linecolor=:auto, linewidth=:auto,
        dashtype=:auto, pointtype=:auto, pointsize=:auto,
        title="", xlabel="", ylabel="", xlims=:auto, ylims=:auto) = 
    plot(1:length(x),x,label=label,style=style,linecolor=linecolor,
        linewidth=linewidth,dashtype=dashtype,pointtype=pointtype,
        pointsize=pointsize,title=title,xlabel=xlabel,ylabel=ylabel,
        xlims=xlims,ylims=ylims)


plot!(x::AbstractVector;
        label="", style=:line, linecolor=:auto, linewidth=:auto,
        dashtype=:auto, pointtype=:auto, pointsize=:auto,
        title="", xlabel="", ylabel="", xlims=:auto, ylims=:auto) = 
    plot!(1:length(x),x,label=label,style=style,linecolor=linecolor,
        linewidth=linewidth,dashtype=dashtype,pointtype=pointtype,
        pointsize=pointsize,title=title,xlabel=xlabel,ylabel=ylabel,
        xlims=xlims,ylims=ylims)



function plot(x::AbstractVector, y::AbstractVector;
        label="", style=:line, linecolor=:auto, linewidth=:auto,
        dashtype=:auto, pointtype=:auto, pointsize=:auto,
        title="", xlabel="", ylabel="", xlims=:auto, ylims=:auto)
    global figures
    data = DiscreteData2D(x, y; label=label, style=style, linecolor=linecolor,
        linewidth=linewidth, dashtype=dashtype, pointtype=pointtype, pointsize=pointsize)
    fig = Figure2D([data], title=title, xlabel=xlabel, ylabel=ylabel,
    	xlims=xlims, ylims=ylims)
    push!(figures, fig)
    fig
end


function plot!(x::AbstractVector, y::AbstractVector;
        label="", style=:line, linecolor=:auto, linewidth=:auto,
        dashtype=:auto, pointtype=:auto, pointsize=:auto)
    global figures
    fig = figures[end]
    @assert isa(fig, Figure2D)
    data = DiscreteData2D(x, y; label=label, style=style, linecolor=linecolor,
        linewidth=linewidth, dashtype=dashtype, pointtype=pointtype, pointsize=pointsize)
    push!(fig.data, data)
    fig
end




function plot(x::AbstractVector, y::AbstractVector, z::AbstractVector;
        label="", style=:line, linecolor=:auto, linewidth=:auto,
        dashtype=:auto, pointtype=:auto, pointsize=:auto,
        title="", xlabel="", ylabel="", xlims=:auto, ylims=:auto, zlims=:auto)
    global figures
    data = DiscreteData3D(x, y, z; label=label, style=style, linecolor=linecolor,
        linewidth=linewidth, dashtype=dashtype, pointtype=pointtype, pointsize=pointsize)
    fig = Figure3D([data], title=title, xlabel=xlabel, ylabel=ylabel, xlims=xlims,
        ylims=ylims, zlims=zlims)
    push!(figures, fig)
    fig
end

function plot!(x::AbstractVector, y::AbstractVector, z::AbstractVector;
        label="", style=:line, linecolor=:auto, linewidth=:auto,
        dashtype=:auto, pointtype=:auto, pointsize=:auto)
    global figures
    fig = figures[end]
    @assert isa(fig, Figure3D)
    data = DiscreteData3D(x, y, z; label=label, style=style, linecolor=linecolor,
        linewidth=linewidth, dashtype=dashtype, pointtype=pointtype, pointsize=pointsize)
    push!(fig.data, data)
    fig
end


function xlims!(xmin,xmax)
	global figures
    fig = figures[end]
	fig.xlims = (xmin,xmax)
	fig
end

function ylims!(ymin,ymax)
	global figures
    fig = figures[end]
	fig.ylims = (ymin,ymax)
	fig
end

function zlims!(zmin,zmax)
    global figures
    fig = figures[end]
    @assert typeof(fig) == Figure3D
    fig.zlims = (zmin,zmax)
    fig
end


function set_range(fig::Figure2D)
    if fig.xlims != :auto
        send_string("set xrange [$(fig.xlims[1]):$(fig.xlims[2])]")
    end
    if fig.ylims != :auto
        send_string("set yrange [$(fig.ylims[1]):$(fig.ylims[2])]")
    end
end

function set_range(fig::Figure3D)
    if fig.xlims != :auto
        send_string("set xrange [$(fig.xlims[1]):$(fig.xlims[2])]")
    end
    if fig.ylims != :auto
        send_string("set yrange [$(fig.ylims[1]):$(fig.ylims[2])]")
    end
    if fig.zlims != :auto
        send_string("set zrange [$(fig.zlims[1]):$(fig.zlims[2])]")
    end
end


function writemime(io::IO, ::MIME"image/svg+xml", fig::Figure)
    fig.imgfile = tempname()
    set_term("svg dashed")
    set_options(
        output=fig.imgfile,
        title=fig.title,
        xlabel=fig.xlabel,
        ylabel=fig.ylabel,
    )
    set_range(fig)
    write_data(fig)
    plot_figure(fig)
    send_string("unset output")
    finish()
    img = open(readbytes, fig.imgfile, "r")
    write(io, img)
    send_string("reset")
end



ext_to_term = Dict(
    "pdf"  => "pdfcairo",
    "png"  => "pngcairo",
    "svg"  => "svg",
    "eps"  => "epscairo",
    "html" => "canvas",
)


function Base.write(filename::AbstractString, fig::Figure)
    fig.imgfile = filename
    ext = splitext(filename)[2][2:end]     # file extension (without the .)
    term = ext_to_term[ext]                # choose terminal automatically based on file type
    set_term("$term")
    set_options(
        output=fig.imgfile,
        title=fig.title,
        xlabel=fig.xlabel,
        ylabel=fig.ylabel,
    )
    set_range(fig)
    write_data(fig)
    plot_figure(fig)
    send_string("reset")                    # reset all options
    send_string("unset output")             # flushes output
end



# function writemime(io::IO, ::MIME"image/png", fig::Figure)
#     fig.imgfile = tempname()
#     set_term("pngcairo dashed")
#     set_options(
#         output=fig.imgfile,
#         title=fig.title,
#         xlabel=fig.xlabel,
#         ylabel=fig.ylabel
#     )
#     write_data(fig)
#     plot_figure(fig)
#     finish()
#     img = open(readbytes, fig.imgfile, "r")
#     write(io, img)
# end


end  # module Gnuplot
