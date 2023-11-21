abstract type AbstractSamplingModel end

mutable struct EpsilonSamplingModel <: AbstractSamplingModel

    # data -
    α::Array{Float64,1}
    β::Array{Float64,1}
    K::Int64
    ϵ::Float64

    # constructor -
    EpsilonSamplingModel() = new();
end


function sample(model::EpsilonSamplingModel, data::Dict{String,DataFrame}, tickers::Array{String,1}; 𝒯::Int64 = 0)

    # initialize -
    α = model.α
    β = model.β
    K = model.K
    ϵ = model.ϵ
    θ̂_vector = Array{Float64,1}(undef, K)
    time_sample_results_dict_Ts = Dict{Int64, Array{Float64,2}}();

    # generate random Categorical distribution -
    parray = [1/K for i = 1:K]
    dcat = Categorical(parray);
    
    # initialize collection of Beta distributions -
    action_distribution = Array{Beta,1}(undef, K);
    for k ∈ 1:K
        action_distribution[k] = Beta(α[k], β[k]); # initialize uniform
    end
 
    # main sampling loop -
    for t ∈ 1:𝒯

        # create a new parameter array -
        parameter_array = Array{Float64,2}(undef, K, 2);
        fill!(parameter_array, 0.0);

        for k ∈ 1:K
            
            # grab the distribution for action k -
            d = action_distribution[k];

            # store the parameter array -
            αₖ, βₖ = params(d);
            parameter_array[k,1] = αₖ
            parameter_array[k,2] = βₖ

            # store -
            time_sample_results_dict_Ts[t] = parameter_array;
        end

        aₜ = 1; # default to 1
        if (rand() < ϵ)
            aₜ = rand(dcat);
        else
            
            for k ∈ 1:K

                # grab the distribution for action k -
                d = action_distribution[k];
    
                # generate a sample for this action -
                θ̂_vector[k] = rand(d);
            end

            # ok: let's choose an action -
            aₜ = argmax(θ̂_vector);

            # pass that action to the world function, gives back a reward -
            rₜ = _world(aₜ, t, data, tickers);


            # update the parameters -
            # first, get the old parameters -
            old_d = action_distribution[aₜ];
            αₒ,βₒ = params(old_d);

            # update the old values with the new values -
            αₜ = αₒ + rₜ
            βₜ = βₒ + (1-rₜ)

            # @show (aₜ, rₜ,  αₒ, βₒ, αₜ, βₜ)

            # build new distribution -
            action_distribution[aₜ] = Beta(αₜ, βₜ);
        end
    end

    return time_sample_results_dict_Ts;
end

function sample(model::EpsilonSamplingModel, world::Function, data::Dict{String,DataFrame}, tickers::Array{String,1}; 
    horizon::Int64 = 100, buffersize::Int64 = 1, risk_free_rate::Float64 = 0.05)

    # initialize -
    α = model.α
    β = model.β
    K = model.K
    ϵ = model.ϵ
    θ̂_vector = Array{Float64,1}(undef, K)
    time_sample_results_dict_Ts = Dict{Int64, Array{Float64,2}}();
    action_distribution = Array{Beta,1}(undef, K);

    # generate random Categorical distribution -
    parray = [1/K for _ = 1:K]
    dcat = Categorical(parray);
    
    # initialize collection of Beta distributions -
    for k ∈ 1:K
        action_distribution[k] = Beta(α[k], β[k]); # initialize uniform
    end
 
    # main sampling loop -
    for t ∈ 1:horizon

        # create a new parameter array -
        parameter_array = Array{Float64,2}(undef, K, 2);
        fill!(parameter_array, 0.0);

        # for each action, grab the parameters -
        for k ∈ 1:K
            
            # grab the distribution for action k -
            d = action_distribution[k];

            # store the parameter array -
            αₖ, βₖ = params(d);
            parameter_array[k,1] = αₖ
            parameter_array[k,2] = βₖ

            # store -
            time_sample_results_dict_Ts[t] = parameter_array;
        end

        aₜ = nothing; # default to 1
        if (rand() < ϵ)
            aₜ = rand(dcat); # choose a random action uniformly
        else
            
            for k ∈ 1:K

                # grab the distribution for action k -
                d = action_distribution[k];
    
                # generate a sample for this action -
                θ̂_vector[k] = rand(d);
            end

            # ok: let's choose an action -
            aₜ = argmax(θ̂_vector);

            # pass that action to the world function, gives back a reward -
            rₜ = world(aₜ, t, data, tickers; buffersize = buffersize, risk_free_rate = risk_free_rate);

            # update the parameters -
            # first, get the old parameters -
            old_d = action_distribution[aₜ];
            αₒ,βₒ = params(old_d);

            # update the old values with the new values -
            αₜ = αₒ + rₜ
            βₜ = βₒ + (1-rₜ)

            # build new distribution -
            action_distribution[aₜ] = Beta(αₜ, βₜ);
        end
    end

    return time_sample_results_dict_Ts;
end


function build_beta_array(parameters::Array{Float64,2})::Array{Beta,1}

    # build an array of beta distributions -
    (NR,_) = size(parameters);
    beta_array = Array{Beta,1}(undef,NR)
    for i ∈ 1:NR
        
        # grab the parameters -
        α = parameters[i,1];
        β = parameters[i,2];

        # build -
        beta_array[i] = Beta(α, β);
    end

    # return -
    return beta_array;
end

function preference(beta::Array{Beta,1}, tickers::Array{String,1}; N::Int64 = 100)

    # sample -
    K = length(tickers);
    tmp_array = Array{Int64,1}(undef, N);
    θ̂_vector = Array{Float64,1}(undef, K)
    pref_array = Array{Float64,1}(undef, K)

    # main sampling loop -
    # for i ∈ 1:N # for each sample
    #     for k ∈ 1:K # for each action
            
    #         # grab -
    #         d = beta[k];
            
    #         # generate a sample for this action -
    #         θ̂_vector[k] = rand(d);
    #     end

    #     # ok: let's choose an action -
    #     tmp_array[i] = argmax(θ̂_vector);
    # end

    # Let's compute the mean of each beta distribution -
    for k ∈ 1:K # for each action
        
        # grab -
        d = beta[k];
        α,β = params(d);
        
        # generate a sample for this action -
        θ̂_vector[k] = (α)/(α+β);
    end

    # ok: let's choose an action -


    # # how many of each do we have?
    # for k ∈ 1:K
    #     idx = findall(x->x==k, tmp_array);
    #     pref_array[k] = length(idx)/N;
    # end

    # return -
    return tiedrank(θ̂_vector, rev = true);
end
