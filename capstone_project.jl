using PlotlyJS, CSV, HTTP, DataFrames

# Read data from a csv
df = CSV.File(
    HTTP.get("https://raw.githubusercontent.com/plotly/datasets/master/api_docs/mt_bruno_elevation.csv").body
) |> DataFrame
z_data = Matrix{Float64}(df)'

layout = Layout(
    title="Mt Bruno Elevation",
    autosize=false,
    scene_camera_eye=attr(x=1.87, y=0.88, z=-0.64),
    width=500, height=500,
    margin=attr(l=65, r=50, b=65, t=90)
)
plot(surface(
    z=z_data,
    contours_z=attr(
        show=true,
        usecolormap=true,
        highlightcolor="limegreen",
        project_z=true
    )
), layout)