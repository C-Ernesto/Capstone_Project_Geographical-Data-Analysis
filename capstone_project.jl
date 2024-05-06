using PlotlyJS, CSV, HTTP, DataFrames, Statistics

# TODO Find outliers
function summaryStatistics(myVector)
    mean_elevation = mean(myVector)
    median_elevation = median(myVector)
    std_deviation = std(myVector)
    min_elevation = minimum(myVector)
    max_elevation = maximum(myVector)
    q1, q2, q3 = quantile(myVector, [0.25, 0.5, 0.75])

    println("----- Descriptive Analysis -----")
    println("Mean: ", mean_elevation)
    println("Median: ", median_elevation)
    println("Standard Deviation: ", std_deviation)
    println("Minimum Elevation: ", min_elevation)
    println("Maximum Elevation: ", max_elevation)
    println("Quartile 1: ", q1)
    println("Quartile 2: ", q2)
    println("Quartile 3: ", q3)
end

function create_histogram(z_data_vector)
    z_data_histogram = plot(
        histogram(
            x = z_data_vector,
            nbins = 10,
            opacity = 0.7,
            marker_color = "blue",
            name = "Elevation Histogram"
        ),
        Layout(
            title = "Mt.Bruno Elevation Histogram",
            xaxis = attr(title = "Elevation"),
            yaxis = attr(title = "Frequency")
        )
    )
    display(z_data_histogram)
end

function create_boxPlot(z_data_vector)
    z_data_boxplot = plot(
        box(
            y=z_data_vector, 
            boxpoints="all", 
            quartilemethod="linear", 
            name="linear"
        ),
        Layout(
            title = "Box Plot",
            xaxis_title = "Mt.Bruno",
            yaxis_title = "Elevation"
        )
    )
    display(z_data_boxplot)
end

# function to make path
function generate_random_path(A, B; grid_size=(25, 25), weight_factor=0.6)
    x_coords = [A[1]]
    y_coords = [A[2]]
    current_position = A
    while current_position != B
        # Calculate direction towards B
        dx = B[1] - current_position[1]
        dy = B[2] - current_position[2]

        # If not reached B, randomly move towards B with a weighted probability
        if dx != 0 || dy != 0
            if rand() < weight_factor
                dx = sign(dx)
            else
                dx = rand([-1, 1])
            end
            if rand() < weight_factor
                dy = sign(dy)
            else
                dy = rand([-1, 1])
            end
        end

        # Update next position
        next_position = (current_position[1] + dx, current_position[2] + dy)
        
        # Ensure next position is within grid bounds
        if 1 <= next_position[1] <= grid_size[1] && 1 <= next_position[2] <= grid_size[2]
            push!(x_coords, next_position[1])
            push!(y_coords, next_position[2])
            current_position = next_position
        end
    end
    return x_coords, y_coords
end

# Read data from a csv
df = CSV.File(
    HTTP.get("https://raw.githubusercontent.com/plotly/datasets/master/api_docs/mt_bruno_elevation.csv").body
) |> DataFrame

# convert data to 2D array and vector, print summary
z_data = Matrix{Float64}(df)
(sh_0, sh_1) = size(z_data)
z_data_vector = vec(z_data)
summaryStatistics(z_data_vector)

# Histogram, Boxplot
create_histogram(z_data_vector)
create_boxPlot(z_data_vector)

# make X and Y axis enumerate from 0
x = range(1, length=sh_0)
y = range(1, length=sh_1)

# Pick random corner on grid
A = (rand([1, 25]), rand([1, 25]))

# Get highest elevation
max_idx = argmax(z_data)
max_x, max_y = max_idx[1], max_idx[2]
B = (max_x, max_y)

# get a random path from A to B
x_path, y_path = generate_random_path(A, B)

# get heights for each x and y coords in path
z_path = []
for (xi, yi) in zip(x_path, y_path)
    # add height to points for visiblity
    val = z_data[xi, yi] + 3
    push!(z_path, val)
end

# make layout for plot
layout = Layout(
    title="Mt Bruno Elevation",
    scene = attr(xaxis_title="x", yaxis_title="y", zaxis_title="Elevation"),
    autosize=false,
    scene_camera_eye=attr(x=1.87, y=0.88, z=-0.64),
    width=1000, height=1000,
    margin=attr(l=65, r=50, b=65, t=90)
)

# plot elevation data
trace1 = surface(
    z=z_data,
    x=x,
    y=y,
    contours_z=attr(
        show=true,
        usecolormap=true,
        highlightcolor="limegreen",
        project_z=true
    )
)

# plot random path
trace2 = scatter(x=x_path, y=y_path, z=z_path,
                    marker=attr(size=3),
                    line=attr(color="black", width=2),
                    type="scatter3d",
                    mode="lines+markers")


plot([trace1, trace2], layout)
