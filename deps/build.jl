# Gnuplot.jl
# build dependency: gnuplot-v5

using BinDeps
using Compat

@BinDeps.setup

gnuplot = library_dependency("gnuplot")

@osx_only begin
	using Homebrew
	provides(Homebrew.HB, "gnuplot", gnuplot, os = :Darwin)
end

provides(AptGet, "gnuplot", gnuplot)
provides(Yum, "gnuplot", gnuplot)

julia_usrdir = normpath(JULIA_HOME*"/../") # This is a stopgap, we need a better built-in solution to get the included libraries
libdirs = AbstractString["$(julia_usrdir)/lib"]
includedirs = AbstractString["$(julia_usrdir)/include"]

provides(
	Sources,
	URI("http://sourceforge.net/projects/gnuplot/files/latest/download?source=files"),
	gnuplot
)

provides(
	BuildProcess,
	Autotools(lib_dirs = libdirs, include_dirs = includedirs),
	gnuplot
)



@compat @BinDeps.install Dict(:gnuplot => :gnuplot)



