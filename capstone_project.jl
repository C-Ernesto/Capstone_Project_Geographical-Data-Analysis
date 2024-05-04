using PlotlyJS, CSV, HTTP, DataFrames, Statistics

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

# convert data to 2D array
z_data = Matrix{Float64}(df)
(sh_0, sh_1) = size(z_data)

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
    width=500, height=500,
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


#=
plot(surface(
    z=z_data,
    contours_z=attr(
        show=true,
        usecolormap=true,
        highlightcolor="limegreen",
        project_z=true
    )
), layout)
=#