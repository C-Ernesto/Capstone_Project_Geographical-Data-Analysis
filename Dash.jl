using CSV, HTTP, DataFrames, Dash, PlotlyJS, Statistics

function load_and_process_data()
    url = "https://raw.githubusercontent.com/plotly/datasets/master/api_docs/mt_bruno_elevation.csv"
    df = CSV.File(HTTP.get(url).body) |> DataFrame
    return Matrix{Float64}(df)  # Convert DataFrame to Matrix for processing
end


function summaryStatistics(data::Vector{Float64})
    mean_val = mean(data)
    median_val = median(data)
    std_val = std(data)
    min_val = minimum(data)
    max_val = maximum(data)
    q1 = quantile(data, 0.25)  # 1st quartile
    q2 = quantile(data, 0.50)  # 2nd quartile or median
    q3 = quantile(data, 0.75)  # 3rd quartile

    stats = (
        mean = mean_val,
        median = median_val,
        std = std_val,
        min = min_val,
        max = max_val,
        quartile1 = q1,
        quartile2 = q2,
        quartile3 = q3
    )

    println("Stats: $stats")  # Debug print
    return stats
end

function create_statistics_div(stats)
    println("Creating div with stats: $stats")  # Debug print
    return html_div([
        html_h4("Statistical Summary:"),
        html_p("Mean: $(round(stats.mean, digits=4))"),
        html_p("Median: $(round(stats.median, digits=4))"),
        html_p("Standard Deviation: $(round(stats.std, digits=4))"),
        html_p("Minimum: $(round(stats.min, digits=4))"),
        html_p("Maximum: $(round(stats.max, digits=4))"),
        html_p("1st Quartile: $(round(stats.quartile1, digits=4))"),
        html_p("2nd Quartile (Median): $(round(stats.quartile2, digits=4))"),
        html_p("3rd Quartile: $(round(stats.quartile3, digits=4))")
    ])
end


# Histogram
function create_histogram(data::Vector{Float64})
    trace = histogram(x=data, autobinx=true, marker=attr(color="blue"))
    layout = Layout(title="Data Histogram")
    return plot([trace], layout)
end

# Box Plot
function create_boxPlot(data::Vector{Float64})
    trace = box(y=data, boxpoints="all", jitter=0.5, whiskerwidth=0.2)
    layout = Layout(title="Data Box Plot")
    return plot([trace], layout)
end

function create_3d_elevation_plot()
    X, Y, z_data = load_3d_plot_data()

    layout = Layout(
        title="Mt Bruno Elevation",
        autosize=false,
        scene=attr(
            camera=attr(eye=attr(x=1.87, y=0.88, z=-0.64)),
            xaxis=attr(title="X"),
            yaxis=attr(title="Y"),
            zaxis=attr(title="Elevation")
        ),
        width=500, height=500,
        margin=attr(l=65, r=50, b=65, t=90)
    )

    trace = surface(
        z=z_data,
        x=X, y=Y,  # Pass the X and Y coordinate matrices
        contours_z=attr(
            show=true,
            usecolormap=true,
            highlightcolor="limegreen",
            project_z=true
        )
    )

    return plot([trace], layout)
end


app = dash()


app.layout = html_div() do
    [
        html_h1("Interactive Data Analysis of Mt. Bruno"),
        html_div(id="statistics-output"),  # Placeholder for statistics
        dcc_graph(id="histogram"),
        dcc_graph(id="boxplot"),
        dcc_graph(id="surface-plot"),
        html_button("Update Data", id="update-data", n_clicks=0),

    ]
end

callback!(app, Output("statistics-output", "children"), Input("update-data", "n_clicks")) do clicks
    data = load_and_process_data()
    vector_data = vec(data)  # Flatten the matrix to vector for statistical analysis
    stats = summaryStatistics(vector_data)
    return create_statistics_div(stats)
end


callback!(app, Output("histogram", "figure"), Input("update-data", "n_clicks")) do clicks
    data = load_and_process_data()
    vector_data = vec(data)  # Flatten the matrix to vector for histogram and boxplot
    create_histogram(vector_data)
end

callback!(app, Output("boxplot", "figure"), Input("update-data", "n_clicks")) do clicks
    data = load_and_process_data()
    vector_data = vec(data)
    create_boxPlot(vector_data)
end

callback!(app, Output("surface-plot", "figure"), Input("update-data", "n_clicks")) do clicks
    data = load_and_process_data()
    create_3d_elevation_plot(data)

end

run_server(app, "0.0.0.0", 8050)

