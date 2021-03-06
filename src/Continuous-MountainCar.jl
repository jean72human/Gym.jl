mutable struct Continuous_MountainCarEnv
    min_action
    max_action
    min_position
    max_position
    max_speed
    goal_position
    power

    state
end

function Continuous_MountainCarEnv()
    min_action    =  -1f0
    max_action    =   1f0
    min_position  = -12f-1
    max_position  =   6f-1
    max_speed     =   7f-2
    goal_position =  45f-2 # was 0.5 in gym, 0.45 in Arnaud de Broissia's version
    power         =  15f-4
    Continuous_MountainCarEnv(min_action, max_action, min_position, max_position,
                              max_speed, goal_position, power, nothing)
end

function step!(env::Continuous_MountainCarEnv, action)
    position, velocity = env.state[1:1], env.state[2:2]
    force = clamp.(action, env.min_action, env.max_action)

    v          = velocity .+ force * env.power .- 25f-4cos.(3f0position)
    velocity_  = clamp.(v, -env.max_speed, env.max_speed)
    x          = position .+ velocity_
    position_  = clamp.(x, env.min_position, env.max_position)
    if all(position_ .== env.min_position) && all(velocity_ .< 0)
        velocity_ = 0f0velocity_
    end

    done = all(position_ .≥ env.goal_position)

    r = [0f0]
    if done
        r = [1f2]
    end
    reward = r .- 1f-1action .^ 2

    env.state = vcat(position_, velocity_)
    return env.state, reward, done, Dict()
end

function reset!(env::Continuous_MountainCarEnv)
    env.state = param([2f-1rand(Float32) - 6f-1, 0f0])
end

show(io::IO, env::Continuous_MountainCarEnv) = print(io, "Continuous-MountainCarEnv")
