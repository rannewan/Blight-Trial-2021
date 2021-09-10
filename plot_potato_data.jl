using DataFrames, RDatasets, CSV
using Statistics, StatsBase, Bootstrap
using Plots, StatsPlots, ColorSchemes


maxi_plot = CSV.read("Potato Trial Spraying - Yield Max.csv", header = 1, skipto = 3, DataFrame)
gdf       = groupby( maxi_plot, :Treatment)
display(gdf)

# Calculate mean values of treatments
gdf_blight  = sort( combine(gdf, Symbol("Adjusted Blighted") =>  mean), Symbol("Adjusted Blighted_mean"), rev = false)
gdf_market  = sort( combine(gdf, Symbol("Adjusted Marketable") => mean ), Symbol("Adjusted Marketable_mean"), rev = true)
gdf_small   = sort( combine(gdf, Symbol("Adjusted Small") => mean ), Symbol("Adjusted Small_mean"), rev = true)
gdf_total   = sort( combine(gdf, Symbol("Adjusted Total") => mean ), Symbol("Adjusted Total_mean"), rev = true)

# Show mean values
display(sort(gdf_blight,Symbol("Adjusted Blighted_mean"), rev = false) )
display(sort(gdf_small,Symbol("Adjusted Small_mean"), rev = true) )
display(sort(gdf_market,Symbol("Adjusted Marketable_mean"), rev = true) )

# Query mean value of treatment "Water" through list comprehension
mean_m_water = gdf_market[ [i in ["Manzate"] for i in gdf_market.Treatment ],: ]
mean_b_water = gdf_blight[ [i in ["Manzate"] for i in gdf_blight.Treatment ],: ]
mean_s_water = gdf_small[ [i in ["Manzate"] for i in gdf_small.Treatment ],: ]

# Some statistics

cil = 0.95


# Plot mean values per treatment
gr(color_palette = :PuOr_4)
p = scatter(
    gdf_market[!, :Treatment],
    gdf_market[!, Symbol("Adjusted Marketable_mean")],
    label = "",
    title = "Yields per Treatment",
    ylim = (0,25),
    xrotation = 50,
    framestyle = :semi,
    xlabel = "Treatment",
    ylabel = "Mean [kg]\n ",
    legendfontsize = 7,
    legend = :topright
)
plot!([mean_b_water[1,2]], seriestype="hline", label="", color = :lightgray)
@df gdf_market scatter!(cols(1), cols(2), label = "Market", yerr = [1,1,1,1,1,1,1,1,1,1,1,1,1] )
@df gdf_small scatter!(cols(1), cols(2), label = "Small")
@df gdf_blight scatter!(cols(1), cols(2), label = "Blighted")
@df gdf_total scatter!(cols(1), cols(2), label = "Non-Blighted")
Plots.savefig("scatter_absolute_yield_mean.png")




# --------------
# Absolute Yield
# --------------


names_treaments = unique(maxi_plot[!,:Treatment])
m_water = Vector{Float64}
m_water = names_treatments
]
 = mean_m_water[!,Symbol("Adjusted Marketable_mean")]

# gr(color_palette = :PuOr_6, size = (900,600))
p = plot(title = "Absolute Yields per Treatment",
         ylim = (0,25),
         xrotation = 45,
         framestyle = :semi,
         xlabel = "Treatment",
         ylabel = "Yield [kg]",
         legendfontsize = 7,
         legend = :topleft
)


p = plot(names_treaments,
         ylim = (0,25),
         xrotation = 45,
         framestyle = :semi,
         xlabel = "Treatment",
         ylabel = "Yield [kg]",
         legendfontsize = 7,
         legend = :topleft
)




# Marketable
# ------------------------------------------------------------------------------
p = boxplot!(maxi_plot[!,:Treatment],
              maxi_plot[!,Symbol("Adjusted Marketable")],
              label = "Market",
              fillalpha = 0.75,
              # linewidth = 2,
              xrotation = 45,
              xlabel = "Treatment",
              # ylabel = "Mean of Yield [kg]",
              # legend = false
)

p = dotplot!(maxi_plot[!,:Treatment],
              maxi_plot[!,Symbol("Adjusted Marketable")],
              label = "",
              marker=(:black, stroke(0)),
              group = maxi_plot[!, :Treatment],
              xrotation = 45,
              markersize = 3,
              xlabel = "Treatment",
              # ylabel = "Mean of Yield [kg]",
              # legend = false
)


# Small
# ------------------------------------------------------------------------------
p = boxplot!(maxi_plot[!,:Treatment],
              maxi_plot[!,Symbol("Adjusted Small")],
              label = "Small",
              fillalpha = 0.75,
              # linewidth = 2,
              # group = maxi_plot[!, :Treatment],
              xrotation = 45,
              xlabel = "Treatment",
              # ylabel = "Mean of Yield [kg]",
              # legend = false
)
p = dotplot!(maxi_plot[!,:Treatment],
              maxi_plot[!,Symbol("Adjusted Small")],
              label = "",
              marker=(:black, stroke(0)),
              group = maxi_plot[!, :Treatment],
              xrotation = 45,
              markersize = 3,
              xlabel = "Treatment",
              # ylabel = "Mean of Yield [kg]",
              # legend = false
)

# Blighted
# ------------------------------------------------------------------------------

p = boxplot!(maxi_plot[!,:Treatment],
              maxi_plot[!,Symbol("Adjusted Blighted")],
              label = "Blighted",
              fillalpha = 0.75,
              # linewidth = 2,
              # group = maxi_plot[!, :Treatment],
              xrotation = 45,
              xlabel = "Treatment",
              # ylabel = "Mean of Yield [kg]",
              # legend = false
)
p = dotplot!(maxi_plot[!,:Treatment],
              maxi_plot[!,Symbol("Adjusted Blighted")],
              label = "",
              marker=(:black, stroke(0)),
              group = maxi_plot[!, :Treatment],
              xrotation = 45,
              markersize = 3,
              xlabel = "Treatment",
              # ylabel = "Yield [kg]",
              # legend = false
)

# Means
# ------------------------------------------------------------------------------
@df gdf_market scatter!(cols(1),
                        cols(2),
                        label = "Mean",
                        xlabel = "Treatment",
                        markershape = :star5,
                        markercolor = :white,
                        markersize = 7,
                        # legend = true
                        )
@df gdf_small scatter!(cols(1),
                        cols(2),
                        label = "",
                        xlabel = "Treatment",
                        markershape = :star5,
                        markercolor = :white,
                        markersize = 7,
                        # marker=(:black, stroke(0)),
)

@df gdf_blight scatter!(cols(1),
                        cols(2),
                        label = "",
                        xlabel = "Treatment",
                        markershape = :star5,
                        markercolor = :white,
                        markersize = 7,
                        # marker=(:black, stroke(0)),
)


Plots.savefig("absolute_yield.png")


gdf_small[:Water,Symbol("Adjusted Small_mean")]

# ------------------------------------------------------------------------------
# Proportional
# ------------------------------------------------------------------------------

maxi_plot.cumValue = copy(maxi_plot."Adjusted Blighted")
combine(maxi_plot, :Treatment) do dd
    dd.cumValue .= cumsum(dd."Adjusted Blighted")/2.0
    return
end

maxi_plot.cumValue
maxi_plot."Adjusted Blighted"

for subdf in groupby(maxi_plot, :Treatment)
    subdf.cumValue .= cumsum(subdf."Adjusted Blighted")
end
display(maxi_plot)
names(maxi_plot)

p = plot(title = "Absolute Treatment Yields",
         ylim = (0,25),
         xrotation = 45,
         framestyle = :semi,
         xlabel = "Treatment",
         ylabel = "Mean of Yield [kg]",
         legendfontsize = 7,
         legend = :topleft
    )
# p = violin!(maxi_plot[!,:Treatment],
#                   maxi_plot[!,Symbol("Adjusted Marketable")],
#                   linewidth = 0,
#                   # group = maxi_plot[!, :Treatment],
#                   xrotation = 45,
#                   xlabel = "Treatment",
#                   ylabel = "Mean of Yield [kg]",
#                   legend = false
# )
p = boxplot!(maxi_plot[!,:Treatment],
                  maxi_plot[!,Symbol("Adjusted Marketable")],
                  label = "Market",
                  fillalpha = 0.75,
                  # linewidth = 2,
                  xrotation = 45,
                  xlabel = "Treatment",
                  ylabel = "Mean of Yield [kg]",
                  # legend = false
)
p = dotplot!(maxi_plot[!,:Treatment],
                  maxi_plot[!,Symbol("Adjusted Marketable")],
                  label = "",
                  marker=(:black, stroke(0)),
                  group = maxi_plot[!, :Treatment],
                  xrotation = 45,
                  xlabel = "Treatment",
                  ylabel = "Mean of Yield [kg]",
                  # legend = false
)


# Plot Small
# ------------------------------------------------------------------------------
p = boxplot!(maxi_plot[!,:Treatment],
                  maxi_plot[!,Symbol("Adjusted Small")],
                  label = "Small",
                  fillalpha = 0.75,
                  # linewidth = 2,
                  # group = maxi_plot[!, :Treatment],
                  xrotation = 45,
                  xlabel = "Treatment",
                  ylabel = "Mean of Yield [kg]",
                  # legend = false
)
p = dotplot!(maxi_plot[!,:Treatment],
                  maxi_plot[!,Symbol("Adjusted Small")],
                  label = "",
                  marker=(:black, stroke(0)),
                  group = maxi_plot[!, :Treatment],
                  xrotation = 45,
                  xlabel = "Treatment",
                  ylabel = "Mean of Yield [kg]",
                  # legend = false
)

p = boxplot!(maxi_plot[!,:Treatment],
                  maxi_plot[!,Symbol("Adjusted Blighted")],
                  label = "Blighted",
                  fillalpha = 0.75,
                  # linewidth = 2,
                  # group = maxi_plot[!, :Treatment],
                  xrotation = 45,
                  xlabel = "Treatment",
                  ylabel = "Mean of Yield [kg]",
                  # legend = false
)
p = dotplot!(maxi_plot[!,:Treatment],
                  maxi_plot[!,Symbol("Adjusted Blighted")],
                  label = "",
                  marker=(:black, stroke(0)),
                  group = maxi_plot[!, :Treatment],
                  xrotation = 45,
                  xlabel = "Treatment",
                  ylabel = "Mean of Yield [kg]",
                  # legend = false
)



@df gdf_market scatter!(cols(1),
                        cols(2),
                        label = "Mean",
                        markershape = :star5,
                        markersize = 7,
                        # legend = true
                        )
@df gdf_small scatter!(cols(1),
                        cols(2),
                        label = "",
                        markershape = :star5,
                        markersize = 7,
                        # marker=(:black, stroke(0)),
)

@df gdf_blight scatter!(cols(1),
                        cols(2),
                        label = "",
                        markershape = :star5,
                        markersize = 7,
                        # marker=(:black, stroke(0)),
)


Plots.savefig("absolute_yield.png")
