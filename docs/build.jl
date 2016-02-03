
using Docile, Lexicon, Gnuplot

# config = Config()
config = Config(md_subheader=:skip, mathjax = true)

index = save("Gnuplot.md", Gnuplot, config)
save("index.md", Index([index]), config)

# run(`../mkdocs build`)
# mkdocs gh-deploy --clean

