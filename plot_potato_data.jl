# Tested with Julia 1.6.1

using DataFrames, RDatasets
using CSV
using Statistics, StatsBase, Bootstrap
using Plots, StatsPlots, ColorSchemes

# Read data and group into treatments
maxi_plot = CSV.read("Potato Trial Spraying - Yield Max.csv", header = 1, skipto = 3, DataFrame, missingstrings=["NA", "na", "n/a", "missing"])
dropmissing!(maxi_plot)
gdf       = groupby( maxi_plot, :Treatment)

# Calculate mean, variance and standard deviation of treatments
gdf_blight  = combine(gdf, Symbol("Adjusted Blighted") =>  mean)
display(combine(gdf, Symbol("Adjusted Blighted") =>  var))
gdf_blight[!,:var] = combine(gdf, Symbol("Adjusted Blighted") =>  var)[:,2]
gdf_blight[!,:sd] = combine(gdf, Symbol("Adjusted Blighted") =>  (s -> sqrt(var(s))))[:,2]
rename!(gdf_blight, Symbol("Adjusted Blighted_mean") => :mean)
sort!(gdf_blight, :mean, rev = false)

gdf_market  = combine(gdf, Symbol("Adjusted Marketable") =>  mean)
display(combine(gdf, Symbol("Adjusted Marketable") =>  var))
gdf_market[!,:var] = combine(gdf, Symbol("Adjusted Marketable") =>  var)[:,2]
gdf_market[!,:sd] = combine(gdf, Symbol("Adjusted Marketable") =>  (s -> sqrt(var(s))))[:,2]
rename!(gdf_market, Symbol("Adjusted Marketable_mean") => :mean)
sort!(gdf_market, :mean, rev = true)

gdf_small  = combine(gdf, Symbol("Adjusted Small") =>  mean)
display(combine(gdf, Symbol("Adjusted Small") =>  var))
gdf_small[!,:var] = combine(gdf, Symbol("Adjusted Small") =>  var)[:,2]
gdf_small[!,:sd] = combine(gdf, Symbol("Adjusted Small") =>  (s -> sqrt(var(s))))[:,2]
rename!(gdf_small, Symbol("Adjusted Small_mean") => :mean)
sort!(gdf_small, :mean, rev = true)
#
# gdf_total   = combine(gdf, Symbol("Adjusted Total") =>  mean)
# display(combine(gdf, Symbol("Adjusted Small") =>  var))
# gdf_total[!,:var] = combine(gdf, Symbol("Adjusted Total") =>  var)[:,2]
# gdf_total[!,:sd] = combine(gdf, Symbol("Adjusted Total") =>  (s -> sqrt(var(s))))[:,2]
# rename!(gdf_total, Symbol("Adjusted Total_mean") => :mean)
# sort!(gdf_total, :mean, rev = true)

# Show mean values
display(gdf_blight)
display(gdf_small)
display(gdf_market)

# Query mean value of treatment "Water" through list comprehension
mean_m_water = gdf_market[ [i in ["Manzate"] for i in gdf_market.Treatment ],: ]
mean_b_water = gdf_blight[ [i in ["Manzate"] for i in gdf_blight.Treatment ],: ]
mean_s_water = gdf_small[ [i in ["Manzate"] for i in gdf_small.Treatment ],: ]

# Create big dataframe for calculation of proportional data
gdf_all = innerjoin(gdf_market, gdf_small, gdf_blight, on =:Treatment, makeunique = true)
rename!(gdf_all,
        :mean => :mean_market,
        :var => :var_market,
        :sd => :sd_market,
        :mean_1 => :mean_small,
        :var_1 => :var_small,
        :sd_1 => :sd_small,
        :mean_2 => :mean_blight,
        :var_2 => :var_blight,
        :sd_2 => :sd_blight
)

# Calculate fractional values of mean values per treatment
mean_m_frac = transform(gdf_all,
                         [:mean_market, :mean_small, :mean_blight] =>
                         ( (m,s,b) -> (m./(m+s+b))) => :mean_m_frac
)
mean_s_frac = transform(gdf_all,
                        [:mean_market, :mean_small, :mean_blight] =>
                        ( (m,s,b) -> (s./(m+s+b))) => :mean_s_frac
)
mean_b_frac = transform(gdf_all,
                        [:mean_market, :mean_small, :mean_blight] =>
                        ( (m,s,b) -> (b./(m+s+b))) => :mean_b_frac
)

# Trim dataframe
select!(mean_m_frac, Not(:mean_market))
select!(mean_m_frac, Not(:var_market))
select!(mean_m_frac, Not(:sd_market))
select!(mean_m_frac, Not(:mean_small))
select!(mean_m_frac, Not(:var_small))
select!(mean_m_frac, Not(:sd_small))
select!(mean_m_frac, Not(:mean_blight))
select!(mean_m_frac, Not(:var_blight))
select!(mean_m_frac, Not(:sd_blight))
select!(mean_s_frac, Not(:mean_market))
select!(mean_s_frac, Not(:var_market))
select!(mean_s_frac, Not(:sd_market))
select!(mean_s_frac, Not(:mean_small))
select!(mean_s_frac, Not(:var_small))
select!(mean_s_frac, Not(:sd_small))
select!(mean_s_frac, Not(:mean_blight))
select!(mean_s_frac, Not(:var_blight))
select!(mean_s_frac, Not(:sd_blight))
select!(mean_b_frac, Not(:mean_market))
select!(mean_b_frac, Not(:var_market))
select!(mean_b_frac, Not(:sd_market))
select!(mean_b_frac, Not(:mean_small))
select!(mean_b_frac, Not(:var_small))
select!(mean_b_frac, Not(:sd_small))
select!(mean_b_frac, Not(:mean_blight))
select!(mean_b_frac, Not(:var_blight))
select!(mean_b_frac, Not(:sd_blight))

# Show mean values
display( sort(mean_m_frac, :mean_m_frac, rev = false))
display( sort(mean_s_frac, :mean_s_frac, rev = true))
display( sort(mean_b_frac, :mean_b_frac, rev = true))





# False flag to check whether treatment produces mostly marketable
sort!(mean_m_frac, :Treatment, rev = false)
sort!(mean_s_frac, :Treatment, rev = false)
sort!(mean_b_frac, :Treatment, rev = false)
cnames = mean_m_frac[:, :Treatment]
A = [mean_m_frac[:,2] mean_s_frac[:,2] mean_b_frac[:,2]]
B = A[sortperm(A[:,3]), :]
C = cnames[sortperm(A[:,3]), :]
ctx = repeat(["Marketable", "Small", "Blighted"])


# Plot stacked Diagram
groupedbar(vec(C), B,
           title = "Blight per Treatment",
           bar_position = :stack,
           xrotation = 45,
           labels = "",
           xlabel = "Treatment",
           ylabel = "Fraction [-]",
           # legend = :topright,
           # group = ctx
           )
Plots.savefig("Blight_Proportion.png")




# Plot mean values per treatment
gr(color_palette = :PuOr_4)
p = scatter(
    # gdf_market[!, :Treatment],
    # gdf_market[!, :mean],
    label = "",
    title = "Yields per Treatment",
    ylim = (0,25),
    xrotation = 50,
    framestyle = :semi,
    xlabel = "Treatment",
    ylabel = " \nMean ± Std Dev [kg]\n ",
    legendfontsize = 7,
    legend = :topright
)
@df gdf_market scatter!(cols(1), cols(2), label = "Marketable", yerr = cols(4), markersize = 5)
@df gdf_small scatter!(cols(1), cols(2), label = "Small", yerr = cols(4), markersize = 5)
@df gdf_blight scatter!(cols(1), cols(2), label = "Blighted", yerr = cols(4), markersize = 5)
plot!([mean_b_water[1,2]], seriestype="hline", label="", color = :lightgray)
# @df gdf_blight scatter!(cols(1), cols(2), label = "", yerr = cols(4))

p = dotplot!(maxi_plot[!,:Treatment],
                maxi_plot[!,Symbol("Adjusted Marketable")],
                label = "",
                marker=(:black, stroke(0)),
                group = maxi_plot[!, :Treatment],
                xrotation = 45,
                markersize = 2,
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
                markersize = 2,
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
              markersize = 2,
              xlabel = "Treatment",
              # ylabel = "Yield [kg]",
              # legend = false
)

# @df gdf_total scatter!(cols(1), cols(2), label = "Non-Blighted")
Plots.savefig("yield_means.png")




# --------------
# Absolute Yield
# --------------

gr(color_palette = :PuOr_4)
p = plot(title = "Yield per Treatment",
         ylim = (0,25),
         xrotation = 45,
         framestyle = :semi,
         xlabel = "Treatment",
         ylabel = "Yield [kg]",
         legendfontsize = 7,
         legend = :topleft
)
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
display(p)
Plots.savefig("yield.png")
