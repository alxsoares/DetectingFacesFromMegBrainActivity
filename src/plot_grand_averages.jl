require("src/helpers.jl")
using DataFrames
using Gadfly
using MAT

data_path   = ARGS[1]
output_path = ensure_empty_directory_exists(ARGS[2])

function plot_grand_average(average, title)
    channels = repmat([1:size(average, 1)], 1, size(average, 2)) 
    time     = repmat(transpose([1:size(average, 2)]), size(average, 1), 1)
    df = DataFrame(Response=vec(average), Channels=vec(channels), Time=vec(time))
    p = plot(df, x="Time", y="Channels", color="Response", Geom.rectbin)
    draw(PNG(joinpath(output_path, @sprintf("%s.png", title)), 20cm, 15cm), p)

    grand_average = reshape(mean(average, 1), size(average,2))
    df_grand_average = DataFrame(Response=grand_average, Time=[1:length(grand_average)])
    p = plot(df_grand_average, x="Time", y="Response", Geom.line)
    draw(PNG(joinpath(output_path, @sprintf("Average-%s.png", title)), 20cm, 15cm), p)
end

function plot_fft(X, sampling_rate, title)
    power = vec(mean(abs(rfft(X, 3)), (1,2)))
    frequencies = linspace(sampling_rate/2/length(power), sampling_rate/2, length(power))
    df = DataFrame(Frequencies=frequencies, Power=power)
    p = plot(df, x="Frequencies", y="Power", Geom.line)
    draw(PNG(joinpath(output_path, @sprintf("FFT-%s.png", title)), 20cm, 15cm), p)
end

for subject=train_subjects
    f = matopen(joinpath(data_path, subject_file(subject)))
    X     = read(f, "X")
    sfreq = read(f, "sfreq")
    plot_fft(X, sfreq, @sprintf("Subject %d-Face", subject))
    #(b,a) = power_filter(sfreq, 50)
    #apply_filter!(X, b, a)
    #(b,a) = power_filter(sfreq, 100)
    #apply_filter!(X, b, a)
    (b,a) = low_pass_filter(sfreq, 40)
    apply_filter!(X, b, a)
    plot_fft(X, sfreq, @sprintf("After Subject %d-Face", subject))
    num_channels     = size(X,2)
    num_time_samples = size(X,3)
    y = read(f, "y")
    face    = reshape(mean(X[vec(y).==1,:,:], 1), num_channels, num_time_samples)
    no_face = reshape(mean(X[vec(y).!=1,:,:], 1), num_channels, num_time_samples)
    plot_grand_average(face, @sprintf("Subject %d-Face", subject))
    plot_grand_average(no_face, @sprintf("Subject %d-No Face", subject))
end
